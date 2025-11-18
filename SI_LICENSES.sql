{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT REPLACE(UUID_STRING(), '-', ''), 'SI_LICENSES', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT REPLACE(UUID_STRING(), '-', ''), 'SI_LICENSES', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

/* Transform Bronze Licenses to Silver Licenses with enhanced data quality checks */
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

cleaned_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        
        /* Critical P1: DD/MM/YYYY date format conversion */
        COALESCE(
            TRY_TO_DATE(START_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE, 'DD-MM-YYYY'),
            TRY_TO_DATE(START_DATE, 'MM/DD/YYYY'),
            TRY_TO_DATE(START_DATE)
        ) AS START_DATE,
        
        COALESCE(
            TRY_TO_DATE(END_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE, 'DD-MM-YYYY'),
            TRY_TO_DATE(END_DATE, 'MM/DD/YYYY'),
            TRY_TO_DATE(END_DATE)
        ) AS END_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_licenses
),

validated_licenses AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL
                AND END_DATE IS NOT NULL
                AND END_DATE >= START_DATE
            THEN 100
            WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL
                AND END_DATE IS NOT NULL
                AND END_DATE >= START_DATE
            THEN 'PASSED'
            WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_licenses
),

deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_licenses
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
WHERE rn = 1
    AND VALIDATION_STATUS != 'FAILED'
