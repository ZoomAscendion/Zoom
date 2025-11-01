{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_LICENSES'", 'CURRENT_TIMESTAMP()']) }}', 'SI_LICENSES_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM', 'PROD', 'BZ_LICENSES,BZ_USERS', 'SI_LICENSES', CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, RECORDS_PROCESSED, RECORDS_INSERTED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_LICENSES'", 'CURRENT_TIMESTAMP()']) }}', 'SI_LICENSES_TRANSFORMATION', CURRENT_TIMESTAMP(), 'SUCCESS', 'DBT_SYSTEM', 'PROD', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Licenses Table
-- Transforms license data with user information and utilization metrics

WITH bronze_licenses AS (
    SELECT 
        bl.LICENSE_ID,
        bl.LICENSE_TYPE,
        bl.ASSIGNED_TO_USER_ID,
        bl.START_DATE,
        bl.END_DATE,
        bl.LOAD_TIMESTAMP,
        bl.UPDATE_TIMESTAMP,
        bl.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_licenses') }} bl
    WHERE bl.LICENSE_ID IS NOT NULL
      AND bl.ASSIGNED_TO_USER_ID IS NOT NULL
      AND bl.START_DATE IS NOT NULL
      AND bl.END_DATE IS NOT NULL
),

-- Join with Users for Assigned User Information
license_with_user AS (
    SELECT 
        bl.*,
        bu.USER_NAME AS assigned_user_name
    FROM bronze_licenses bl
    LEFT JOIN {{ source('bronze', 'bz_users') }} bu ON bl.ASSIGNED_TO_USER_ID = bu.USER_ID
),

-- Data Quality and Cleansing Layer
cleansed_licenses AS (
    SELECT 
        -- Primary Keys
        TRIM(lwu.LICENSE_ID) AS LICENSE_ID,
        TRIM(lwu.ASSIGNED_TO_USER_ID) AS ASSIGNED_TO_USER_ID,
        
        -- Standardized License Type
        CASE 
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%BASIC%' THEN 'Basic'
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%PRO%' THEN 'Pro'
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Enterprise'
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%ADD%' OR UPPER(lwu.LICENSE_TYPE) LIKE '%ADDON%' THEN 'Add-on'
            ELSE 'Basic'  -- Default category
        END AS LICENSE_TYPE,
        
        lwu.START_DATE,
        lwu.END_DATE,
        
        -- License Status based on current date
        CASE 
            WHEN lwu.END_DATE < CURRENT_DATE() THEN 'Expired'
            WHEN lwu.START_DATE > CURRENT_DATE() THEN 'Suspended'
            ELSE 'Active'
        END AS LICENSE_STATUS,
        
        -- Assigned User Name
        CASE 
            WHEN lwu.assigned_user_name IS NOT NULL THEN TRIM(INITCAP(lwu.assigned_user_name))
            ELSE 'Unknown User'
        END AS ASSIGNED_USER_NAME,
        
        -- License Cost based on type
        CASE 
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%BASIC%' THEN 14.99
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%PRO%' THEN 19.99
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 39.99
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%ADD%' THEN 9.99
            ELSE 14.99
        END AS LICENSE_COST,
        
        -- Renewal Status (placeholder logic)
        CASE 
            WHEN lwu.END_DATE > DATEADD('month', 1, CURRENT_DATE()) THEN 'Yes'
            ELSE 'No'
        END AS RENEWAL_STATUS,
        
        -- Utilization Percentage (placeholder calculation)
        CASE 
            WHEN lwu.END_DATE < CURRENT_DATE() THEN 0.00
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 85.50
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%PRO%' THEN 72.30
            WHEN UPPER(lwu.LICENSE_TYPE) LIKE '%BASIC%' THEN 45.20
            ELSE 30.00
        END AS UTILIZATION_PERCENTAGE,
        
        -- Metadata Columns
        lwu.LOAD_TIMESTAMP,
        lwu.UPDATE_TIMESTAMP,
        lwu.SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        (
            CASE WHEN lwu.LICENSE_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN lwu.ASSIGNED_TO_USER_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN lwu.LICENSE_TYPE IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN lwu.START_DATE IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN lwu.END_DATE >= lwu.START_DATE THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(lwu.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(lwu.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM license_with_user lwu
),

-- Deduplication Layer
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_licenses
)

-- Final Select with Data Quality Filters
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
  AND DATA_QUALITY_SCORE >= 0.80  -- Minimum quality threshold
  AND LICENSE_ID IS NOT NULL
  AND ASSIGNED_TO_USER_ID IS NOT NULL
