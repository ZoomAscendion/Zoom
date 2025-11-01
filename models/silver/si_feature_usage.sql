{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_FEATURE_USAGE'", 'CURRENT_TIMESTAMP()']) }}', 'SI_FEATURE_USAGE_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM', 'PROD', 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, RECORDS_PROCESSED, RECORDS_INSERTED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_FEATURE_USAGE'", 'CURRENT_TIMESTAMP()']) }}', 'SI_FEATURE_USAGE_TRANSFORMATION', CURRENT_TIMESTAMP(), 'SUCCESS', 'DBT_SYSTEM', 'PROD', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Feature Usage Table
-- Transforms feature usage data with categorization and duration calculations

WITH bronze_feature_usage AS (
    SELECT 
        bfu.USAGE_ID,
        bfu.MEETING_ID,
        bfu.FEATURE_NAME,
        bfu.USAGE_COUNT,
        bfu.USAGE_DATE,
        bfu.LOAD_TIMESTAMP,
        bfu.UPDATE_TIMESTAMP,
        bfu.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_feature_usage') }} bfu
    WHERE bfu.USAGE_ID IS NOT NULL
      AND bfu.MEETING_ID IS NOT NULL
      AND bfu.FEATURE_NAME IS NOT NULL
      AND bfu.USAGE_COUNT >= 0
),

-- Data Quality and Cleansing Layer
cleansed_feature_usage AS (
    SELECT 
        -- Primary Keys
        TRIM(bfu.USAGE_ID) AS USAGE_ID,
        TRIM(bfu.MEETING_ID) AS MEETING_ID,
        
        -- Cleansed Business Columns
        TRIM(UPPER(bfu.FEATURE_NAME)) AS FEATURE_NAME,
        
        COALESCE(bfu.USAGE_COUNT, 0) AS USAGE_COUNT,
        
        -- Calculate Usage Duration (estimated based on feature type and count)
        CASE 
            WHEN UPPER(bfu.FEATURE_NAME) LIKE '%SCREEN_SHARE%' THEN bfu.USAGE_COUNT * 5  -- 5 min per usage
            WHEN UPPER(bfu.FEATURE_NAME) LIKE '%CHAT%' THEN bfu.USAGE_COUNT * 1  -- 1 min per message
            WHEN UPPER(bfu.FEATURE_NAME) LIKE '%RECORDING%' THEN bfu.USAGE_COUNT * 30  -- 30 min per recording
            WHEN UPPER(bfu.FEATURE_NAME) LIKE '%BREAKOUT%' THEN bfu.USAGE_COUNT * 15  -- 15 min per breakout
            ELSE bfu.USAGE_COUNT * 2  -- Default 2 min per usage
        END AS USAGE_DURATION,
        
        -- Feature Categorization
        CASE 
            WHEN UPPER(bfu.FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(bfu.FEATURE_NAME) LIKE '%MICROPHONE%' OR UPPER(bfu.FEATURE_NAME) LIKE '%MUTE%' THEN 'Audio'
            WHEN UPPER(bfu.FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(bfu.FEATURE_NAME) LIKE '%CAMERA%' OR UPPER(bfu.FEATURE_NAME) LIKE '%SCREEN_SHARE%' THEN 'Video'
            WHEN UPPER(bfu.FEATURE_NAME) LIKE '%CHAT%' OR UPPER(bfu.FEATURE_NAME) LIKE '%WHITEBOARD%' OR UPPER(bfu.FEATURE_NAME) LIKE '%ANNOTATION%' OR UPPER(bfu.FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Collaboration'
            WHEN UPPER(bfu.FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(bfu.FEATURE_NAME) LIKE '%PASSWORD%' OR UPPER(bfu.FEATURE_NAME) LIKE '%WAITING_ROOM%' THEN 'Security'
            ELSE 'Collaboration'  -- Default category
        END AS FEATURE_CATEGORY,
        
        bfu.USAGE_DATE,
        
        -- Metadata Columns
        bfu.LOAD_TIMESTAMP,
        bfu.UPDATE_TIMESTAMP,
        bfu.SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        (
            CASE WHEN bfu.USAGE_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bfu.MEETING_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bfu.FEATURE_NAME IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bfu.USAGE_COUNT >= 0 THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(bfu.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bfu.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_feature_usage bfu
),

-- Deduplication Layer
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_feature_usage
)

-- Final Select with Data Quality Filters
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
FROM deduped_feature_usage
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.75  -- Minimum quality threshold
  AND USAGE_ID IS NOT NULL
  AND MEETING_ID IS NOT NULL
