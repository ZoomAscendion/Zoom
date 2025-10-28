{{ config(
    materialized='table'
) }}

-- Gold Feature Dimension Table
WITH feature_data AS (
    SELECT DISTINCT
        feature_name,
        feature_category,
        usage_pattern,
        load_date,
        update_date,
        source_system
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE feature_name IS NOT NULL
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY feature_name) as feature_dimension_id,
    COALESCE(feature_name, 'Unknown Feature') as feature_name,
    COALESCE(feature_category, 'General') as feature_category,
    CASE 
        WHEN feature_name LIKE '%screen%' THEN 'Screen sharing and collaboration feature'
        WHEN feature_name LIKE '%chat%' THEN 'Communication and messaging feature'
        WHEN feature_name LIKE '%record%' THEN 'Recording and playback feature'
        WHEN feature_name LIKE '%poll%' THEN 'Engagement and interaction feature'
        ELSE CONCAT('Platform feature: ', feature_name)
    END as feature_description,
    CASE 
        WHEN feature_category = 'Core' THEN 'Essential'
        WHEN feature_category = 'Premium' THEN 'Advanced'
        ELSE 'Standard'
    END as feature_type,
    CASE 
        WHEN feature_category = 'Premium' THEN 'Pro, Business, Enterprise'
        WHEN feature_category = 'Enterprise' THEN 'Enterprise Only'
        ELSE 'All Plans'
    END as availability_plan,
    'Active' as feature_status,
    '2020-01-01'::DATE as launch_date,
    -- Additional columns from Silver layer
    COALESCE(usage_pattern, 'Standard') as usage_pattern,
    -- Metadata columns
    COALESCE(load_date, CURRENT_DATE()) as load_date,
    COALESCE(update_date, CURRENT_DATE()) as update_date,
    COALESCE(source_system, 'ZOOM_PLATFORM') as source_system
FROM feature_data
