{{ config(
    materialized='table',
    cluster_by=['date_id', 'feature_id']
) }}

-- Create sample feature usage fact data
with sample_feature_usage as (
    select
        1 as feature_usage_id,
        
        -- Foreign keys to dimensions
        (select date_id from {{ ref('dim_date') }} where date_value = current_date limit 1) as date_id,
        1 as feature_id,
        1 as user_dim_id,
        
        -- Usage identifiers
        'MEET001' as meeting_id,
        current_date as usage_date,
        current_timestamp as usage_timestamp,
        'Screen Share' as feature_name,
        
        -- Usage metrics
        5 as usage_count,
        60 as usage_duration_minutes,
        60 as session_duration_minutes,
        
        -- Calculated metrics
        4.0 as feature_adoption_score,
        4.5 as user_experience_rating,
        5.0 as feature_performance_score,
        1 as concurrent_features_count,
        
        -- Usage context
        'Standard Session' as usage_context,
        'Desktop' as device_type,
        'Latest' as platform_version,
        0 as error_count,
        100.0 as success_rate,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as feature_usage_id,
        
        -- Foreign keys to dimensions
        (select date_id from {{ ref('dim_date') }} where date_value = current_date limit 1) as date_id,
        3 as feature_id,
        1 as user_dim_id,
        
        -- Usage identifiers
        'MEET001' as meeting_id,
        current_date as usage_date,
        current_timestamp as usage_timestamp,
        'Chat' as feature_name,
        
        -- Usage metrics
        25 as usage_count,
        60 as usage_duration_minutes,
        60 as session_duration_minutes,
        
        -- Calculated metrics
        5.0 as feature_adoption_score,
        4.8 as user_experience_rating,
        5.0 as feature_performance_score,
        2 as concurrent_features_count,
        
        -- Usage context
        'Standard Session' as usage_context,
        'Desktop' as device_type,
        'Latest' as platform_version,
        0 as error_count,
        100.0 as success_rate,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_feature_usage
