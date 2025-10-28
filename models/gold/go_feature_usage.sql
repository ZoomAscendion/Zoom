{{ config(
    materialized='table'
) }}

-- Gold Feature Usage Table (Enhanced from Silver)
SELECT 
    ROW_NUMBER() OVER (ORDER BY feature_usage_id) as feature_usage_gold_id,
    feature_usage_id,
    meeting_id,
    COALESCE(feature_name, 'Unknown Feature') as feature_name,
    COALESCE(usage_count, 0) as usage_count,
    usage_date,
    COALESCE(usage_duration_minutes, 0) as usage_duration_minutes,
    COALESCE(feature_category, 'General') as feature_category,
    COALESCE(usage_pattern, 'Standard') as usage_pattern,
    -- Metadata columns
    COALESCE(load_date, CURRENT_DATE()) as load_date,
    COALESCE(update_date, CURRENT_DATE()) as update_date,
    COALESCE(source_system, 'ZOOM_PLATFORM') as source_system
FROM {{ source('silver', 'si_feature_usage') }}
