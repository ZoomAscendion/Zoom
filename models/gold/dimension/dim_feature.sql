{{ config(
    materialized='table',
    cluster_by=['feature_id', 'feature_category']
) }}

-- Create sample feature dimension
with sample_features as (
    select
        1 as feature_id,
        'Screen Share' as feature_name,
        'Collaboration' as feature_category,
        'Standard' as feature_type,
        'Medium' as feature_complexity,
        true as is_premium_feature,
        '2020-01-01'::date as feature_release_date,
        'Active' as feature_status,
        'High' as usage_frequency_category,
        'Screen sharing functionality for meetings' as feature_description,
        'All Users' as target_user_segment,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as feature_id,
        'Recording' as feature_name,
        'Recording' as feature_category,
        'Advanced' as feature_type,
        'High' as feature_complexity,
        true as is_premium_feature,
        '2020-01-01'::date as feature_release_date,
        'Active' as feature_status,
        'Medium' as usage_frequency_category,
        'Meeting recording functionality' as feature_description,
        'Pro Users' as target_user_segment,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        3 as feature_id,
        'Chat' as feature_name,
        'Communication' as feature_category,
        'Core' as feature_type,
        'Low' as feature_complexity,
        false as is_premium_feature,
        '2020-01-01'::date as feature_release_date,
        'Active' as feature_status,
        'High' as usage_frequency_category,
        'In-meeting chat functionality' as feature_description,
        'All Users' as target_user_segment,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_features
