{{ config(
    materialized='table',
    cluster_by=['date_id', 'host_user_dim_id']
) }}

-- Create sample meeting activity fact data
with sample_meeting_activity as (
    select
        1 as meeting_activity_id,
        
        -- Foreign keys to dimensions
        (select date_id from {{ ref('dim_date') }} where date_value = current_date limit 1) as date_id,
        1 as meeting_type_id,
        1 as host_user_dim_id,
        
        -- Meeting identifiers
        'MEET001' as meeting_id,
        current_date as meeting_date,
        current_timestamp as meeting_start_time,
        current_timestamp + interval '1 hour' as meeting_end_time,
        
        -- Meeting metrics
        60 as scheduled_duration_minutes,
        60 as actual_duration_minutes,
        5 as participant_count,
        5 as unique_participants,
        60 as host_duration_minutes,
        300 as total_participant_minutes,
        60.0 as average_participation_minutes,
        
        -- Engagement metrics
        5 as peak_concurrent_participants,
        0 as late_joiners_count,
        0 as early_leavers_count,
        
        -- Feature usage metrics
        3 as features_used_count,
        15 as screen_share_duration_minutes,
        0 as recording_duration_minutes,
        25 as chat_messages_count,
        2 as file_shares_count,
        0 as breakout_rooms_used,
        1 as polls_conducted,
        
        -- Quality metrics
        4.5 as meeting_quality_score,
        5.0 as audio_quality_score,
        5.0 as video_quality_score,
        0 as connection_issues_count,
        4.0 as meeting_satisfaction_score,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as meeting_activity_id,
        
        -- Foreign keys to dimensions
        (select date_id from {{ ref('dim_date') }} where date_value = current_date - 1 limit 1) as date_id,
        2 as meeting_type_id,
        2 as host_user_dim_id,
        
        -- Meeting identifiers
        'MEET002' as meeting_id,
        current_date - 1 as meeting_date,
        current_timestamp - interval '1 day' as meeting_start_time,
        current_timestamp - interval '1 day' + interval '30 minutes' as meeting_end_time,
        
        -- Meeting metrics
        30 as scheduled_duration_minutes,
        30 as actual_duration_minutes,
        3 as participant_count,
        3 as unique_participants,
        30 as host_duration_minutes,
        90 as total_participant_minutes,
        30.0 as average_participation_minutes,
        
        -- Engagement metrics
        3 as peak_concurrent_participants,
        1 as late_joiners_count,
        0 as early_leavers_count,
        
        -- Feature usage metrics
        2 as features_used_count,
        5 as screen_share_duration_minutes,
        0 as recording_duration_minutes,
        10 as chat_messages_count,
        0 as file_shares_count,
        0 as breakout_rooms_used,
        0 as polls_conducted,
        
        -- Quality metrics
        3.5 as meeting_quality_score,
        4.5 as audio_quality_score,
        4.0 as video_quality_score,
        1 as connection_issues_count,
        3.5 as meeting_satisfaction_score,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_meeting_activity
