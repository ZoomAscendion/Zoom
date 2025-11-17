{{ config(
    materialized='table'
) }}

-- Silver Layer Feature Usage Table Transformation
-- Transforms Bronze BZ_FEATURE_USAGE to Silver SI_FEATURE_USAGE with data quality checks

WITH bronze_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_FEATURE_USAGE') }}
),

validated_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) as FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        CASE 
            WHEN USAGE_ID IS NULL THEN 0
            WHEN MEETING_ID IS NULL THEN 20
            WHEN FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 30
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 THEN 40
            WHEN USAGE_DATE IS NULL THEN 50
            ELSE 100
        END as DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN USAGE_ID IS NULL OR MEETING_ID IS NULL OR FEATURE_NAME IS NULL OR LENGTH(TRIM(FEATURE_NAME)) = 0 THEN 'FAILED'
            WHEN USAGE_COUNT IS NULL OR USAGE_COUNT < 0 OR USAGE_DATE IS NULL THEN 'FAILED'
            ELSE 'PASSED'
        END as VALIDATION_STATUS
    FROM bronze_feature_usage
),

deduped_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM validated_feature_usage
    WHERE USAGE_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
      AND LENGTH(TRIM(FEATURE_NAME)) > 0
      AND USAGE_COUNT IS NOT NULL
      AND USAGE_COUNT >= 0
      AND USAGE_DATE IS NOT NULL
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) as LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) as UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
WHERE rn = 1
