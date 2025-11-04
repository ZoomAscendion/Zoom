{{ config(
    materialized='table'
) }}

-- Silver Layer Feature Usage Table
-- Transforms Bronze feature usage data with categorization and validations

WITH bronze_feature_usage AS (
    SELECT *
    FROM {{ source('bronze', 'bz_feature_usage') }}
),

-- Data Quality Validations
validated_feature_usage AS (
    SELECT 
        f.*,
        CASE 
            WHEN f.usage_id IS NULL THEN 'CRITICAL_MISSING_ID'
            WHEN f.meeting_id IS NULL THEN 'CRITICAL_MISSING_MEETING_ID'
            WHEN f.feature_name IS NULL OR TRIM(f.feature_name) = '' THEN 'CRITICAL_MISSING_FEATURE_NAME'
            WHEN f.usage_count IS NOT NULL AND f.usage_count < 0 THEN 'CRITICAL_NEGATIVE_COUNT'
            ELSE 'VALID'
        END AS data_quality_status,
        
        -- Calculate data quality score
        CASE 
            WHEN f.usage_id IS NOT NULL 
                AND f.meeting_id IS NOT NULL
                AND f.feature_name IS NOT NULL
                AND TRIM(f.feature_name) != ''
                AND (f.usage_count IS NULL OR f.usage_count >= 0)
            THEN 1.00
            ELSE 0.70
        END AS data_quality_score,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY f.usage_id ORDER BY f.update_timestamp DESC, f.load_timestamp DESC) AS rn
    FROM bronze_feature_usage f
    WHERE f.usage_id IS NOT NULL
        AND f.meeting_id IS NOT NULL
        AND f.feature_name IS NOT NULL
        AND TRIM(f.feature_name) != ''
        AND (f.usage_count IS NULL OR f.usage_count >= 0)
),

-- Apply transformations
transformed_feature_usage AS (
    SELECT 
        vf.usage_id,
        vf.meeting_id,
        TRIM(UPPER(vf.feature_name)) AS feature_name,
        COALESCE(vf.usage_count, 0) AS usage_count,
        
        -- Derive usage duration from usage count
        CASE 
            WHEN vf.usage_count > 0 THEN vf.usage_count * 5  -- Assume 5 minutes per usage
            ELSE 0
        END AS usage_duration,
        
        -- Categorize features
        CASE 
            WHEN UPPER(vf.feature_name) LIKE '%AUDIO%' OR UPPER(vf.feature_name) LIKE '%MICROPHONE%' OR UPPER(vf.feature_name) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(vf.feature_name) LIKE '%VIDEO%' OR UPPER(vf.feature_name) LIKE '%CAMERA%' OR UPPER(vf.feature_name) LIKE '%SCREEN%' THEN 'Video'
            WHEN UPPER(vf.feature_name) LIKE '%CHAT%' OR UPPER(vf.feature_name) LIKE '%SHARE%' OR UPPER(vf.feature_name) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(vf.feature_name) LIKE '%SECURITY%' OR UPPER(vf.feature_name) LIKE '%PASSWORD%' OR UPPER(vf.feature_name) LIKE '%LOCK%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        
        vf.usage_date,
        
        -- Metadata columns
        vf.load_timestamp,
        vf.update_timestamp,
        vf.source_system,
        vf.data_quality_score,
        DATE(vf.load_timestamp) AS load_date,
        DATE(vf.update_timestamp) AS update_date
    FROM validated_feature_usage vf
    WHERE vf.rn = 1
        AND vf.data_quality_status = 'VALID'
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
FROM transformed_feature_usage
