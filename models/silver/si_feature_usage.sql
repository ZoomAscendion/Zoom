{{ config(
    materialized='table'
) }}

-- Silver Layer Feature Usage Transformation
-- Source: Bronze.BZ_FEATURE_USAGE
-- Target: Silver.SI_FEATURE_USAGE
-- Description: Transforms and standardizes feature usage data with categorization

WITH bronze_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE usage_id IS NOT NULL
      AND meeting_id IS NOT NULL
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        usage_id,
        meeting_id,
        
        -- Standardize feature name
        CASE 
            WHEN feature_name IS NULL OR TRIM(feature_name) = '' THEN 'Unknown Feature'
            ELSE TRIM(UPPER(feature_name))
        END AS feature_name_clean,
        
        -- Validate usage count
        CASE 
            WHEN usage_count IS NULL OR usage_count < 0 THEN 0
            ELSE usage_count
        END AS usage_count_clean,
        
        -- Validate usage date
        CASE 
            WHEN usage_date IS NULL THEN DATE(load_timestamp)
            WHEN usage_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE usage_date
        END AS usage_date_clean,
        
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_feature_usage
),

-- Add derived fields
derived_fields AS (
    SELECT 
        *,
        -- Derive usage duration from usage count (simplified logic)
        CASE 
            WHEN usage_count_clean > 0 THEN usage_count_clean * 2
            ELSE 0
        END AS usage_duration,
        
        -- Categorize features
        CASE 
            WHEN feature_name_clean ILIKE '%AUDIO%' OR feature_name_clean ILIKE '%MICROPHONE%' OR feature_name_clean ILIKE '%SOUND%' THEN 'Audio'
            WHEN feature_name_clean ILIKE '%VIDEO%' OR feature_name_clean ILIKE '%CAMERA%' OR feature_name_clean ILIKE '%SCREEN%' THEN 'Video'
            WHEN feature_name_clean ILIKE '%CHAT%' OR feature_name_clean ILIKE '%SHARE%' OR feature_name_clean ILIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN feature_name_clean ILIKE '%SECURITY%' OR feature_name_clean ILIKE '%PASSWORD%' OR feature_name_clean ILIKE '%LOCK%' THEN 'Security'
            ELSE 'General'
        END AS feature_category
    FROM data_quality_checks
),

-- Calculate data quality score
quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        (
            CASE WHEN feature_name_clean != 'Unknown Feature' THEN 0.30 ELSE 0 END +
            CASE WHEN usage_count_clean > 0 THEN 0.25 ELSE 0 END +
            CASE WHEN usage_date_clean IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN feature_category != 'General' THEN 0.20 ELSE 0 END
        ) AS data_quality_score
    FROM derived_fields
),

-- Remove duplicates keeping the most recent record
deduped_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name_clean AS feature_name,
        usage_count_clean AS usage_count,
        usage_duration,
        feature_category,
        usage_date_clean AS usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY update_timestamp DESC) AS rn
    FROM quality_scored
    WHERE data_quality_score >= {{ var('dq_score_threshold') }}
)

SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_duration,
    feature_category,
    usage_date,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    DATE(load_timestamp) AS load_date,
    DATE(update_timestamp) AS update_date
FROM deduped_feature_usage
WHERE rn = 1
  AND usage_count >= 0
