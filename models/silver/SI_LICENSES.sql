{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, PROCESS_STATUS, PROCESS_START_TIME, EXECUTED_BY, AUDIT_TIMESTAMP) SELECT 'SI_LICENSES', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, PROCESS_STATUS, PROCESS_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, AUDIT_TIMESTAMP) SELECT 'SI_LICENSES', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Licenses table
-- Applies data quality checks and DD/MM/YYYY date format conversion (Critical P1)

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
    WHERE LICENSE_ID IS NOT NULL
),

-- Data quality validation and cleansing with DD/MM/YYYY date format conversion
cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        TRIM(UPPER(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        -- Handle DD/MM/YYYY date format (Critical P1 fix for "27/08/2024" error)
        CASE 
            WHEN START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY')
            ELSE START_DATE
        END AS START_DATE,
        CASE 
            WHEN END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY')
            ELSE END_DATE
        END AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality scoring
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL
                AND END_DATE > START_DATE
            THEN 100
            WHEN LICENSE_ID IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 75
            WHEN LICENSE_ID IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        -- Validation status
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 'PASSED'
            WHEN LICENSE_ID IS NULL OR ASSIGNED_TO_USER_ID IS NULL
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_licenses
),

-- Remove duplicates and failed records
deduped_licenses AS (
    SELECT *
    FROM cleansed_licenses
    WHERE rn = 1
      AND VALIDATION_STATUS != 'FAILED'
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
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
