{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Transform Bronze Licenses to Silver with DD/MM/YYYY date format conversion */
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

cleaned_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        
        /* Critical P1: DD/MM/YYYY date format conversion ("27/08/2024" error fix) */
        CASE 
            WHEN TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') IS NOT NULL THEN
                TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY')
            ELSE 
                COALESCE(
                    TRY_TO_DATE(START_DATE, 'YYYY-MM-DD'),
                    TRY_TO_DATE(START_DATE, 'MM/DD/YYYY'),
                    TRY_TO_DATE(START_DATE)
                )
        END AS CLEAN_START_DATE,
        
        CASE 
            WHEN TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') IS NOT NULL THEN
                TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY')
            ELSE 
                COALESCE(
                    TRY_TO_DATE(END_DATE, 'YYYY-MM-DD'),
                    TRY_TO_DATE(END_DATE, 'MM/DD/YYYY'),
                    TRY_TO_DATE(END_DATE)
                )
        END AS CLEAN_END_DATE,
        
        START_DATE AS ORIGINAL_START_DATE,
        END_DATE AS ORIGINAL_END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_licenses
    WHERE LICENSE_ID IS NOT NULL
),

validated_licenses AS (
    SELECT 
        *,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        /* Data quality score calculation */
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND CLEAN_START_DATE IS NOT NULL 
                AND CLEAN_END_DATE IS NOT NULL
                AND CLEAN_END_DATE >= CLEAN_START_DATE
            THEN 100
            WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND CLEAN_START_DATE IS NOT NULL 
                AND CLEAN_END_DATE IS NOT NULL
                AND CLEAN_END_DATE >= CLEAN_START_DATE
            THEN 'PASSED'
            WHEN LICENSE_ID IS NULL OR ASSIGNED_TO_USER_ID IS NULL 
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleaned_licenses
),

deduped_licenses AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
        FROM validated_licenses
    )
    WHERE rn = 1
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    CLEAN_START_DATE AS START_DATE,
    CLEAN_END_DATE AS END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
