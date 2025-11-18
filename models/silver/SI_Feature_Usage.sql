{{ config(
    materialized='table'
) }}

-- Silver Layer Feature Usage Table
-- Cleansed and standardized platform feature usage data

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
    FROM BRONZE.BZ_FEATURE_USAGE
    WHERE USAGE_ID IS NOT NULL
),

cleansed_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        
        /* Clean usage count - handle potential text units */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(USAGE_COUNT::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(USAGE_COUNT::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(USAGE_COUNT::STRING)
        END AS USAGE_COUNT,
        
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_feature_usage
),

validated_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        /* Data quality score calculation */
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT IS NOT NULL
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
            THEN 100
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND FEATURE_NAME IS NOT NULL 
                AND USAGE_COUNT IS NOT NULL
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
            THEN 'PASSED'
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND FEATURE_NAME IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_feature_usage
),

/* Remove duplicates - keep latest record */
deduped_feature_usage AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
        FROM validated_feature_usage
    ) ranked
    WHERE rn = 1
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
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_feature_usage
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
