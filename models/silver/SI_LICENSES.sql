{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

/* Silver layer licenses table with Critical P1 DD/MM/YYYY date format conversion */

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_LICENSES') }}
),

format_conversion AS (
    SELECT 
        *,
        /* Critical P1: DD/MM/YYYY date format conversion */
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'DD-MM-YYYY')
        ) AS converted_start_date,
        
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'DD-MM-YYYY')
        ) AS converted_end_date
    FROM bronze_licenses
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data quality score calculation */
        (
            CASE WHEN LICENSE_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN LICENSE_TYPE IS NOT NULL AND LENGTH(TRIM(LICENSE_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN ASSIGNED_TO_USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN converted_start_date IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN converted_end_date IS NOT NULL AND converted_end_date >= converted_start_date THEN 20 ELSE 0 END
        ) AS data_quality_score,
        
        /* Validation status */
        CASE 
            WHEN LICENSE_ID IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 'FAILED'
            WHEN converted_start_date IS NULL OR converted_end_date IS NULL THEN 'FAILED'
            WHEN converted_end_date < converted_start_date THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM format_conversion
),

cleaned_data AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        converted_start_date AS START_DATE,
        converted_end_date AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score,
        validation_status
    FROM data_quality_checks
    WHERE LICENSE_ID IS NOT NULL
    AND ASSIGNED_TO_USER_ID IS NOT NULL
    AND converted_start_date IS NOT NULL
    AND converted_end_date IS NOT NULL
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleaned_data
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
    data_quality_score AS DATA_QUALITY_SCORE,
    validation_status AS VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
AND validation_status != 'FAILED'
