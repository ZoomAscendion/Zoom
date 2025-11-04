{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_LIC'), 'Silver_Licenses_ETL', CURRENT_TIMESTAMP(), 'Started', 'BRONZE.BZ_LICENSES,BRONZE.BZ_USERS', 'SILVER.SI_LICENSES', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Processing licenses data from Bronze to Silver', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_LIC_END'), 'Silver_Licenses_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Licenses Table Transformation
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
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE LICENSE_ID IS NOT NULL
      AND ASSIGNED_TO_USER_ID IS NOT NULL
),

user_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ ref('si_users') }}
),

validated_licenses AS (
    SELECT 
        l.LICENSE_ID,
        l.ASSIGNED_TO_USER_ID,
        
        CASE 
            WHEN l.LICENSE_TYPE IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN l.LICENSE_TYPE
            ELSE 'Basic'
        END AS LICENSE_TYPE,
        
        CASE 
            WHEN l.START_DATE > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE l.START_DATE
        END AS START_DATE,
        
        CASE 
            WHEN l.END_DATE < l.START_DATE THEN DATEADD('year', 1, l.START_DATE)
            ELSE l.END_DATE
        END AS END_DATE,
        
        CASE 
            WHEN l.END_DATE < CURRENT_DATE() THEN 'Expired'
            WHEN l.START_DATE > CURRENT_DATE() THEN 'Suspended'
            ELSE 'Active'
        END AS LICENSE_STATUS,
        
        COALESCE(u.USER_NAME, 'Unknown User') AS ASSIGNED_USER_NAME,
        
        CASE 
            WHEN l.LICENSE_TYPE = 'Basic' THEN 14.99
            WHEN l.LICENSE_TYPE = 'Pro' THEN 19.99
            WHEN l.LICENSE_TYPE = 'Enterprise' THEN 39.99
            WHEN l.LICENSE_TYPE = 'Add-on' THEN 9.99
            ELSE 0.00
        END AS LICENSE_COST,
        
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), l.END_DATE) <= 30 THEN 'Yes'
            ELSE 'No'
        END AS RENEWAL_STATUS,
        
        CASE 
            WHEN l.LICENSE_TYPE = 'Enterprise' THEN 85.5
            WHEN l.LICENSE_TYPE = 'Pro' THEN 72.3
            WHEN l.LICENSE_TYPE = 'Basic' THEN 45.8
            ELSE 25.0
        END AS UTILIZATION_PERCENTAGE,
        
        l.LOAD_TIMESTAMP,
        l.UPDATE_TIMESTAMP,
        l.SOURCE_SYSTEM,
        
        (
            CASE WHEN l.LICENSE_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN l.ASSIGNED_TO_USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN l.LICENSE_TYPE IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(l.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(l.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_licenses l
    LEFT JOIN user_info u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
),

deduped_licenses AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_licenses
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
FROM deduped_licenses
WHERE rn = 1
  AND START_DATE IS NOT NULL
  AND END_DATE IS NOT NULL
  AND END_DATE >= START_DATE
  AND DATA_QUALITY_SCORE >= 0.75
