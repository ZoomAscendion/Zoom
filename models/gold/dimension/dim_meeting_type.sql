{{ config(
    materialized='table',
    cluster_by=['meeting_type_id', 'time_of_day_category']
) }}

-- Create sample meeting type dimension
with sample_meeting_types as (
    select
        1 as meeting_type_id,
        'Standard Meeting' as meeting_type,
        'Standard Meeting' as meeting_category,
        'Standard' as duration_category,
        'Medium Groups' as participant_size_category,
        'Morning' as time_of_day_category,
        'Monday' as day_of_week,
        false as is_weekend_meeting,
        false as is_recurring_type,
        8.0 as meeting_quality_threshold,
        'Screen Share, Chat, Recording' as typical_features_used,
        'Business Meeting' as business_purpose,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as meeting_type_id,
        'Quick Sync' as meeting_type,
        'Quick Sync' as meeting_category,
        'Brief' as duration_category,
        'Small Groups' as participant_size_category,
        'Afternoon' as time_of_day_category,
        'Tuesday' as day_of_week,
        false as is_weekend_meeting,
        true as is_recurring_type,
        7.0 as meeting_quality_threshold,
        'Chat, Screen Share' as typical_features_used,
        'Team Sync' as business_purpose,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_meeting_types
