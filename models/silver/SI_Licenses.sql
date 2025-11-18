{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver layer transformation for Licenses table with DD/MM/YYYY date format handling */
WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_LICENSES') }}
),

date_cleaning AS (
    SELECT 
        *,
        /* Critical P1: DD/MM/YYYY date format conversion */
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(START_DATE)
        ) AS cleaned_start_date,
        
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(END_DATE)
        ) AS cleaned_end_date
    FROM bronze_licenses
),

data_quality_checks AS (
    SELECT 
        *,
        /* Validate license date logic */
        CASE 
            WHEN cleaned_start_date >= cleaned_end_date THEN 'INVALID_DATE_LOGIC'
            ELSE 'VALID'
        END AS date_validation,
        
        /* Data quality score calculation */
        (
            CASE WHEN LICENSE_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN LICENSE_TYPE IS NOT NULL AND LENGTH(TRIM(LICENSE_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN ASSIGNED_TO_USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN cleaned_start_date IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN cleaned_end_date IS NOT NULL AND cleaned_end_date > cleaned_start_date THEN 20 ELSE 0 END
        ) AS data_quality_score,
        
        /* Validation status */
        CASE 
            WHEN LICENSE_ID IS NULL OR LICENSE_TYPE IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN cleaned_start_date IS NULL OR cleaned_end_date IS NULL THEN 'FAILED'
            WHEN cleaned_start_date >= cleaned_end_date THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM date_cleaning
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE LICENSE_ID IS NOT NULL
),

final_transformation AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        cleaned_start_date AS START_DATE,
        cleaned_end_date AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
    AND validation_status != 'FAILED'
)

SELECT * FROM final_transformation
