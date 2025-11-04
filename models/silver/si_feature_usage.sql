{{ config(
    materialized='table'
) }}

-- Silver Feature Usage Table - Standardized feature usage data
-- Includes feature categorization and usage metrics

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
),

-- Data Quality Validation and Cleansing
feature_usage_cleaned AS (
    SELECT
        bfu.usage_id,
        bfu.meeting_id,
        
        -- Standardize feature names
        CASE 
            WHEN bfu.feature_name IS NULL OR TRIM(bfu.feature_name) = '' THEN 'Unknown Feature'
            ELSE TRIM(UPPER(bfu.feature_name))
        END AS feature_name,
        
        -- Validate usage count
        CASE 
            WHEN bfu.usage_count IS NULL OR bfu.usage_count < 0 THEN 0
            ELSE bfu.usage_count
        END AS usage_count,
        
        -- Calculate usage duration from usage count (simplified logic)
        CASE 
            WHEN bfu.usage_count IS NULL OR bfu.usage_count < 0 THEN 0
            WHEN bfu.usage_count = 0 THEN 0
            ELSE bfu.usage_count * 2  -- Assume 2 minutes per usage on average
        END AS usage_duration,
        
        -- Categorize features
        CASE 
            WHEN UPPER(bfu.feature_name) LIKE '%AUDIO%' OR UPPER(bfu.feature_name) LIKE '%MICROPHONE%' OR UPPER(bfu.feature_name) LIKE '%MUTE%'
                THEN 'Audio'
            WHEN UPPER(bfu.feature_name) LIKE '%VIDEO%' OR UPPER(bfu.feature_name) LIKE '%CAMERA%' OR UPPER(bfu.feature_name) LIKE '%SCREEN%'
                THEN 'Video'
            WHEN UPPER(bfu.feature_name) LIKE '%CHAT%' OR UPPER(bfu.feature_name) LIKE '%SHARE%' OR UPPER(bfu.feature_name) LIKE '%WHITEBOARD%'
                THEN 'Collaboration'
            WHEN UPPER(bfu.feature_name) LIKE '%SECURITY%' OR UPPER(bfu.feature_name) LIKE '%PASSWORD%' OR UPPER(bfu.feature_name) LIKE '%LOCK%'
                THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        
        -- Validate usage date
        CASE 
            WHEN bfu.usage_date IS NULL THEN CURRENT_DATE()
            WHEN bfu.usage_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE bfu.usage_date
        END AS usage_date,
        
        -- Metadata columns
        bfu.load_timestamp,
        bfu.update_timestamp,
        bfu.source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN bfu.usage_id IS NOT NULL 
                AND bfu.meeting_id IS NOT NULL
                AND bfu.feature_name IS NOT NULL AND TRIM(bfu.feature_name) != ''
                AND bfu.usage_count IS NOT NULL AND bfu.usage_count >= 0
                AND bfu.usage_date IS NOT NULL
                THEN 1.00
            WHEN bfu.usage_id IS NOT NULL AND bfu.meeting_id IS NOT NULL
                THEN 0.75
            WHEN bfu.usage_id IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(bfu.load_timestamp) AS load_date,
        DATE(bfu.update_timestamp) AS update_date
        
    FROM bronze_feature_usage bfu
    WHERE bfu.usage_id IS NOT NULL     -- Block records without usage_id
        AND bfu.meeting_id IS NOT NULL -- Block records without meeting_id
),

-- Remove duplicates - keep latest record
feature_usage_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY usage_id ORDER BY update_timestamp DESC) AS rn
    FROM feature_usage_cleaned
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
    load_date,
    update_date
FROM feature_usage_deduped
WHERE rn = 1
    AND data_quality_score >= 0.50  -- Only high quality records
