{{ config(
    materialized='table'
) }}

-- Silver Layer Feature Usage Table
-- Transforms Bronze feature usage data with standardization and categorization

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
        AND MEETING_ID IS NOT NULL
),

-- Data Quality Checks and Transformations
feature_usage_cleaned AS (
    SELECT 
        -- Primary identifiers
        USAGE_ID,
        MEETING_ID,
        
        -- Feature name standardization
        CASE 
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'Unknown Feature'
            ELSE TRIM(UPPER(FEATURE_NAME))
        END AS FEATURE_NAME,
        
        -- Usage count validation
        CASE 
            WHEN USAGE_COUNT < 0 THEN 0
            ELSE COALESCE(USAGE_COUNT, 0)
        END AS USAGE_COUNT,
        
        -- Usage duration derivation (estimated from usage count)
        CASE 
            WHEN USAGE_COUNT < 0 THEN 0
            WHEN USAGE_COUNT = 0 THEN 0
            ELSE COALESCE(USAGE_COUNT, 0) * 2  -- Estimate 2 minutes per usage
        END AS USAGE_DURATION,
        
        -- Feature category mapping
        CASE 
            WHEN UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%AUDIO%' OR UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%MICROPHONE%' OR UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%VIDEO%' OR UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%CAMERA%' OR UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%CHAT%' OR UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%SHARE%' OR UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%SECURITY%' OR UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%PASSWORD%' OR UPPER(TRIM(COALESCE(FEATURE_NAME, ''))) LIKE '%LOCK%' THEN 'Security'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        
        -- Usage date validation
        CASE 
            WHEN USAGE_DATE > CURRENT_DATE() + INTERVAL '1 DAY' THEN CURRENT_DATE()
            ELSE COALESCE(USAGE_DATE, CURRENT_DATE())
        END AS USAGE_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN USAGE_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND FEATURE_NAME IS NOT NULL AND TRIM(FEATURE_NAME) != ''
                AND USAGE_COUNT >= 0
                AND USAGE_DATE IS NOT NULL
                THEN 1.00
            WHEN USAGE_ID IS NOT NULL AND MEETING_ID IS NOT NULL
                THEN 0.75
            WHEN USAGE_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        UPDATE_TIMESTAMP::DATE AS UPDATE_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY USAGE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
        
    FROM bronze_feature_usage
),

-- Final selection with data quality filters
feature_usage_final AS (
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
    FROM feature_usage_cleaned
    WHERE rn = 1  -- Deduplication
        AND USAGE_COUNT >= 0  -- Ensure non-negative usage count
)

SELECT * FROM feature_usage_final
