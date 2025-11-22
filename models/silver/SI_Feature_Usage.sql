{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_FEATURE_USAGE', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_FEATURE_USAGE', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'"
) }}

/* Silver Feature Usage table with data quality checks */
WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
),

/* Clean and validate feature usage data */
validated_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        
        /* Clean usage count */
        CASE 
            WHEN TRY_TO_NUMBER(USAGE_COUNT::STRING) IS NOT NULL AND TRY_TO_NUMBER(USAGE_COUNT::STRING) >= 0 THEN
                TRY_TO_NUMBER(USAGE_COUNT::STRING)
            ELSE 0
        END AS CLEAN_USAGE_COUNT,
        
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        /* Row number for deduplication */
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC NULLS LAST) AS rn
    FROM bronze_feature_usage
    WHERE USAGE_ID IS NOT NULL
),

/* Apply business rules and calculate data quality */
final_feature_usage AS (
    SELECT 
        *,
        /* Data quality score calculation */
        CASE 
            WHEN USAGE_ID IS NULL THEN 0
            WHEN MEETING_ID IS NULL THEN 20
            WHEN FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 40
            WHEN CLEAN_USAGE_COUNT IS NULL THEN 60
            WHEN USAGE_DATE IS NULL THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL THEN 'FAILED'
            WHEN FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 'FAILED'
            WHEN CLEAN_USAGE_COUNT IS NULL OR USAGE_DATE IS NULL THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM validated_feature_usage
    WHERE rn = 1
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    CLEAN_USAGE_COUNT AS USAGE_COUNT,
    USAGE_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM final_feature_usage
WHERE VALIDATION_STATUS != 'FAILED'
