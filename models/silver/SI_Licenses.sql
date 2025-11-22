{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Licenses table with enhanced DD/MM/YYYY date format conversion */
WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_LICENSES') }}
),

/* Clean and validate licenses data */
validated_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        
        /* Critical P1: DD/MM/YYYY date format conversion */
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING)
        ) AS CLEAN_START_DATE,
        
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING)
        ) AS CLEAN_END_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        /* Row number for deduplication */
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC NULLS LAST) AS rn
    FROM bronze_licenses
    WHERE LICENSE_ID IS NOT NULL
),

/* Apply business rules and calculate data quality */
final_licenses AS (
    SELECT 
        *,
        /* Data quality score calculation */
        CASE 
            WHEN LICENSE_ID IS NULL THEN 0
            WHEN ASSIGNED_TO_USER_ID IS NULL THEN 20
            WHEN LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 40
            WHEN CLEAN_START_DATE IS NULL OR CLEAN_END_DATE IS NULL THEN 60
            WHEN CLEAN_END_DATE <= CLEAN_START_DATE THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN LICENSE_ID IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 'FAILED'
            WHEN CLEAN_START_DATE IS NULL OR CLEAN_END_DATE IS NULL THEN 'FAILED'
            WHEN CLEAN_END_DATE <= CLEAN_START_DATE THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM validated_licenses
    WHERE rn = 1
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    CLEAN_START_DATE AS START_DATE,
    CLEAN_END_DATE AS END_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM final_licenses
WHERE VALIDATION_STATUS != 'FAILED'
