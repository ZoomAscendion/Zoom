{{
    config(
        materialized='table',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Feature Usage Transformation
-- Transforms Bronze layer feature usage data with standardization and categorization

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
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
),

-- Data Quality Validations and Cleansing
feature_usage_cleaned AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        
        -- Standardize feature name
        CASE 
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'Unknown Feature'
            ELSE TRIM(UPPER(FEATURE_NAME))
        END AS FEATURE_NAME,
        
        -- Validate usage count
        CASE 
            WHEN USAGE_COUNT < 0 THEN 0
            WHEN USAGE_COUNT > 1000 THEN 1000  -- Cap at reasonable limit
            ELSE COALESCE(USAGE_COUNT, 0)
        END AS USAGE_COUNT,
        
        -- Calculate usage duration (simplified logic)
        CASE 
            WHEN COALESCE(USAGE_COUNT, 0) = 0 THEN 0
            WHEN COALESCE(USAGE_COUNT, 0) <= 5 THEN COALESCE(USAGE_COUNT, 0) * 2
            ELSE COALESCE(USAGE_COUNT, 0) * 1.5
        END AS USAGE_DURATION,
        
        -- Categorize features
        CASE 
            WHEN UPPER(TRIM(FEATURE_NAME)) LIKE '%AUDIO%' OR UPPER(TRIM(FEATURE_NAME)) LIKE '%MICROPHONE%' OR UPPER(TRIM(FEATURE_NAME)) LIKE '%MUTE%' THEN 'Audio'
            WHEN UPPER(TRIM(FEATURE_NAME)) LIKE '%VIDEO%' OR UPPER(TRIM(FEATURE_NAME)) LIKE '%CAMERA%' OR UPPER(TRIM(FEATURE_NAME)) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(TRIM(FEATURE_NAME)) LIKE '%CHAT%' OR UPPER(TRIM(FEATURE_NAME)) LIKE '%SHARE%' OR UPPER(TRIM(FEATURE_NAME)) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(TRIM(FEATURE_NAME)) LIKE '%SECURITY%' OR UPPER(TRIM(FEATURE_NAME)) LIKE '%PASSWORD%' OR UPPER(TRIM(FEATURE_NAME)) LIKE '%LOCK%' THEN 'Security'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN USAGE_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN FEATURE_NAME IS NOT NULL AND TRIM(FEATURE_NAME) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN USAGE_COUNT >= 0 THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_feature_usage
),

-- Remove duplicates keeping the latest record
feature_usage_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM feature_usage_cleaned
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DURATION,
    FEATURE_CATEGORY,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM feature_usage_deduped
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.75  -- Only allow records with at least 75% data quality
