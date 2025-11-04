{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_LICENSES_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_PIPELINE', 'BZ_LICENSES,BZ_USERS', 'SI_LICENSES', CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, RECORDS_PROCESSED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_LICENSES_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)"
) }}

-- Silver Layer Licenses Table Transformation
-- Source: Bronze.BZ_LICENSES with enrichment from BZ_USERS

WITH bronze_licenses AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_LICENSES') }}
),

user_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ source('bronze', 'BZ_USERS') }}
),

-- Data Quality Validation and Cleansing
validated_licenses AS (
    SELECT 
        bl.LICENSE_ID,
        bl.ASSIGNED_TO_USER_ID,
        
        -- Standardize license type
        CASE 
            WHEN bl.LICENSE_TYPE IN ('Basic', 'Pro', 'Enterprise', 'Add-on') 
            THEN bl.LICENSE_TYPE
            ELSE 'Unknown'
        END AS LICENSE_TYPE,
        
        -- Validate and correct date ranges
        CASE 
            WHEN bl.END_DATE < bl.START_DATE THEN bl.END_DATE
            ELSE bl.START_DATE
        END AS START_DATE,
        
        CASE 
            WHEN bl.END_DATE < bl.START_DATE THEN bl.START_DATE
            ELSE bl.END_DATE
        END AS END_DATE,
        
        -- Derive license status from current date vs end date
        CASE 
            WHEN bl.END_DATE >= CURRENT_DATE() THEN 'Active'
            WHEN bl.END_DATE < CURRENT_DATE() THEN 'Expired'
            ELSE 'Suspended'
        END AS LICENSE_STATUS,
        
        -- Assigned user name from users table
        COALESCE(ui.USER_NAME, 'Unknown User') AS ASSIGNED_USER_NAME,
        
        -- Derive cost from license type
        CASE 
            WHEN bl.LICENSE_TYPE = 'Basic' THEN 14.99
            WHEN bl.LICENSE_TYPE = 'Pro' THEN 19.99
            WHEN bl.LICENSE_TYPE = 'Enterprise' THEN 39.99
            WHEN bl.LICENSE_TYPE = 'Add-on' THEN 9.99
            ELSE 0.00
        END AS LICENSE_COST,
        
        -- Derive renewal status from end date proximity
        CASE 
            WHEN bl.END_DATE <= DATEADD('day', 30, CURRENT_DATE()) THEN 'Yes'
            ELSE 'No'
        END AS RENEWAL_STATUS,
        
        -- Calculate utilization percentage (simplified logic)
        CASE 
            WHEN bl.LICENSE_TYPE = 'Enterprise' THEN 85.0
            WHEN bl.LICENSE_TYPE = 'Pro' THEN 70.0
            WHEN bl.LICENSE_TYPE = 'Basic' THEN 55.0
            ELSE 25.0
        END AS UTILIZATION_PERCENTAGE,
        
        bl.LOAD_TIMESTAMP,
        bl.UPDATE_TIMESTAMP,
        bl.SOURCE_SYSTEM,
        
        -- Calculate data quality score
        CASE 
            WHEN bl.LICENSE_ID IS NOT NULL 
                AND bl.ASSIGNED_TO_USER_ID IS NOT NULL
                AND bl.LICENSE_TYPE IS NOT NULL
                AND bl.START_DATE IS NOT NULL
                AND bl.END_DATE IS NOT NULL
                AND bl.END_DATE >= bl.START_DATE
            THEN 1.00
            WHEN bl.LICENSE_ID IS NOT NULL AND bl.ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 0.75
            ELSE 0.50
        END AS DATA_QUALITY_SCORE,
        
        DATE(bl.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bl.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY bl.LICENSE_ID ORDER BY bl.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_licenses bl
    LEFT JOIN user_info ui ON bl.ASSIGNED_TO_USER_ID = ui.USER_ID
    WHERE bl.LICENSE_ID IS NOT NULL
        AND bl.ASSIGNED_TO_USER_ID IS NOT NULL
)

SELECT 
    LICENSE_ID,
    ASSIGNED_TO_USER_ID,
    LICENSE_TYPE,
    START_DATE,
    END_DATE,
    LICENSE_STATUS,
    ASSIGNED_USER_NAME,
    LICENSE_COST,
    RENEWAL_STATUS,
    UTILIZATION_PERCENTAGE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM validated_licenses
WHERE rn = 1
