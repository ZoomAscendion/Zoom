{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_START_TIME, PROCESSED_BY, CREATED_AT) SELECT 'SI_LICENSES', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_END_TIME, PROCESSED_BY, RECORDS_PROCESSED, UPDATED_AT) SELECT 'SI_LICENSES', 'COMPLETED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Licenses table
-- Applies data quality checks and DD/MM/YYYY date format conversion

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
    WHERE LICENSE_ID IS NOT NULL  -- Remove null license IDs
),

data_quality_checks AS (
    SELECT 
        *,
        -- DD/MM/YYYY date format conversion (Critical P1 fix for "27/08/2024" error)
        CASE 
            WHEN START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY')
            ELSE START_DATE
        END AS CLEAN_START_DATE,
        
        CASE 
            WHEN END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY')
            ELSE END_DATE
        END AS CLEAN_END_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_licenses
),

cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        TRIM(UPPER(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        CLEAN_START_DATE AS START_DATE,
        CLEAN_END_DATE AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality score calculation
        CASE 
            WHEN LICENSE_TYPE IS NOT NULL 
                 AND ASSIGNED_TO_USER_ID IS NOT NULL 
                 AND CLEAN_START_DATE IS NOT NULL 
                 AND CLEAN_END_DATE IS NOT NULL 
                 AND CLEAN_END_DATE > CLEAN_START_DATE THEN 100
            WHEN LICENSE_TYPE IS NOT NULL 
                 AND ASSIGNED_TO_USER_ID IS NOT NULL 
                 AND CLEAN_START_DATE IS NOT NULL 
                 AND CLEAN_END_DATE IS NOT NULL THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN LICENSE_TYPE IS NOT NULL 
                 AND ASSIGNED_TO_USER_ID IS NOT NULL 
                 AND CLEAN_START_DATE IS NOT NULL 
                 AND CLEAN_END_DATE IS NOT NULL 
                 AND CLEAN_END_DATE > CLEAN_START_DATE THEN 'PASSED'
            WHEN LICENSE_TYPE IS NOT NULL 
                 AND ASSIGNED_TO_USER_ID IS NOT NULL 
                 AND CLEAN_START_DATE IS NOT NULL 
                 AND CLEAN_END_DATE IS NOT NULL THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM data_quality_checks
    WHERE rn = 1  -- Keep only the latest record for each license
      AND LICENSE_TYPE IS NOT NULL
      AND ASSIGNED_TO_USER_ID IS NOT NULL
      AND CLEAN_START_DATE IS NOT NULL
      AND CLEAN_END_DATE IS NOT NULL
      AND CLEAN_END_DATE > CLEAN_START_DATE  -- Business logic validation
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
    VALIDATION_STATUS,
    CREATED_AT,
    UPDATED_AT
FROM cleansed_licenses
