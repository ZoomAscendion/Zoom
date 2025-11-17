{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) VALUES ('{{ invocation_id }}', 'SI_LICENSES', CURRENT_TIMESTAMP(), 'RUNNING', 'BRONZE.BZ_LICENSES', 'SILVER.SI_LICENSES', 'DBT_PIPELINE', CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}) WHERE EXECUTION_ID = '{{ invocation_id }}' AND TARGET_TABLE = 'SILVER.SI_LICENSES'"
) }}

-- Silver Layer Licenses Table
-- Transforms and cleanses license data from Bronze layer

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

cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        
        -- License type standardization
        CASE 
            WHEN LICENSE_TYPE IS NULL OR TRIM(LICENSE_TYPE) = '' THEN 'STANDARD'
            ELSE UPPER(TRIM(LICENSE_TYPE))
        END AS LICENSE_TYPE,
        
        ASSIGNED_TO_USER_ID,
        
        -- Date validation
        CASE 
            WHEN START_DATE IS NULL THEN DATE(LOAD_TIMESTAMP)
            ELSE START_DATE
        END AS START_DATE,
        
        CASE 
            WHEN END_DATE IS NULL THEN DATEADD('year', 1, COALESCE(START_DATE, DATE(LOAD_TIMESTAMP)))
            WHEN END_DATE < START_DATE THEN DATEADD('year', 1, START_DATE)
            ELSE END_DATE
        END AS END_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Silver layer specific fields
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_licenses
    WHERE LICENSE_ID IS NOT NULL
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score (0-100)
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL
                AND ASSIGNED_TO_USER_ID IS NOT NULL
                AND START_DATE IS NOT NULL
                AND END_DATE IS NOT NULL
                AND START_DATE <= END_DATE
            THEN 100
            WHEN LICENSE_ID IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL
                AND START_DATE IS NOT NULL
                AND END_DATE IS NOT NULL
            THEN 85
            WHEN LICENSE_ID IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 70
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL
                AND START_DATE IS NOT NULL
                AND END_DATE IS NOT NULL
                AND START_DATE <= END_DATE
            THEN 'PASSED'
            WHEN LICENSE_ID IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_licenses
),

-- Remove duplicates keeping the latest record
deduped_licenses AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    )
    WHERE rn = 1
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
WHERE VALIDATION_STATUS != 'FAILED'
