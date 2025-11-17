{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

/* Transform Bronze licenses data to Silver layer with enhanced date format validation */
WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_LICENSES') }}
),

format_cleaned_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        /* Critical P1: DD/MM/YYYY date format conversion */
        COALESCE(
            TRY_TO_DATE(START_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE, 'MM/DD/YYYY'),
            CURRENT_DATE()
        ) AS START_DATE,
        COALESCE(
            TRY_TO_DATE(END_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE, 'MM/DD/YYYY'),
            DATEADD('year', 1, CURRENT_DATE())
        ) AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_licenses
),

validated_licenses AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        /* Data Quality Score Calculation */
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL
                AND END_DATE >= START_DATE
            THEN 100
            WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL THEN 80
            WHEN LICENSE_ID IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        /* Validation Status */
        CASE 
            WHEN LICENSE_ID IS NULL OR LICENSE_TYPE IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN START_DATE IS NULL OR END_DATE IS NULL OR END_DATE < START_DATE THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM format_cleaned_licenses
    WHERE LICENSE_ID IS NOT NULL
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
FROM validated_licenses
WHERE rn = 1
