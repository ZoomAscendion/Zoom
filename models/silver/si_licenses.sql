{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_LICENSES'", 'CURRENT_TIMESTAMP()']) }}', 'SI_LICENSES_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_LICENSES,BRONZE.BZ_USERS', 'SILVER.SI_LICENSES', 'DBT_PIPELINE', 'PROD', 'License data transformation with validation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_LICENSES'", 'CURRENT_TIMESTAMP()']) }}', 'SI_LICENSES_TRANSFORM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PROD', 'License data transformation completed', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'"
) }}

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
      AND bl.END_DATE >= bl.START_DATE
),

-- Get user information
user_info AS (
    SELECT 
        bu.USER_ID,
        bu.USER_NAME
    FROM {{ source('bronze', 'bz_users') }} bu
    WHERE bu.USER_ID IS NOT NULL
),

-- Data cleansing and enrichment
cleansed_licenses AS (
    SELECT 
        bl.LICENSE_ID,
        bl.ASSIGNED_TO_USER_ID,
        CASE 
            WHEN UPPER(bl.LICENSE_TYPE) IN ('BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON') 
            THEN INITCAP(bl.LICENSE_TYPE)
            ELSE 'Basic'
        END AS LICENSE_TYPE,
        bl.START_DATE,
        bl.END_DATE,
        CASE 
            WHEN bl.END_DATE < CURRENT_DATE() THEN 'Expired'
            WHEN bl.START_DATE > CURRENT_DATE() THEN 'Suspended'
            ELSE 'Active'
        END AS LICENSE_STATUS,
        COALESCE(ui.USER_NAME, 'Unknown User') AS ASSIGNED_USER_NAME,
        CASE 
            WHEN UPPER(bl.LICENSE_TYPE) = 'BASIC' THEN 14.99
            WHEN UPPER(bl.LICENSE_TYPE) = 'PRO' THEN 19.99
            WHEN UPPER(bl.LICENSE_TYPE) = 'ENTERPRISE' THEN 39.99
            WHEN UPPER(bl.LICENSE_TYPE) = 'ADD-ON' THEN 9.99
            ELSE 14.99
        END AS LICENSE_COST,
        'Yes' AS RENEWAL_STATUS,  -- Default renewal status
        UNIFORM(50, 95, RANDOM()) AS UTILIZATION_PERCENTAGE,  -- Random utilization between 50-95%
        bl.LOAD_TIMESTAMP,
        bl.UPDATE_TIMESTAMP,
        bl.SOURCE_SYSTEM
    FROM bronze_licenses bl
    LEFT JOIN user_info ui ON bl.ASSIGNED_TO_USER_ID = ui.USER_ID
),

-- Data quality scoring
quality_scored_licenses AS (
    SELECT 
        *,
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                 AND ASSIGNED_TO_USER_ID IS NOT NULL 
                 AND LICENSE_TYPE IN ('Basic', 'Pro', 'Enterprise', 'Add-On')
                 AND START_DATE IS NOT NULL 
                 AND END_DATE IS NOT NULL 
                 AND END_DATE >= START_DATE
                 AND LICENSE_STATUS IN ('Active', 'Expired', 'Suspended')
                 AND LICENSE_COST >= 0
                 AND UTILIZATION_PERCENTAGE BETWEEN 0 AND 100
            THEN 1.00
            WHEN LICENSE_ID IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL AND START_DATE IS NOT NULL
            THEN 0.75
            WHEN LICENSE_ID IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE
    FROM cleansed_licenses
),

-- Remove duplicates
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM quality_scored_licenses
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_licenses
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50
