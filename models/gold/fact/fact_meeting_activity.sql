{{ config(
    materialized='table',
    unique_key='meeting_activity_id'
) }}

with source_meetings as (
    select *
    from {{ source('silver', 'si_meetings') }}
    where validation_status = 'PASSED'
),

source_participants as (
    select *
    from {{ source('silver', 'si_participants') }}
    where validation_status = 'PASSED'
),

source_features as (
    select *
    from {{ source('silver', 'si_feature_usage') }}
    where validation_status = 'PASSED'
),

meeting_aggregates as (
    select 
        sm.meeting_id,
        sm.host_id,
        sm.meeting_topic,
        sm.start_time,
        sm.end_time,
        sm.duration_minutes,
        sm.data_quality_score,
        sm.source_system,
        count(distinct sp.user_id) as participant_count,
        count(distinct sp.participant_id) as unique_participants,
        sum(datediff('minute', sp.join_time, coalesce(sp.leave_time, sm.end_time))) as total_participant_minutes,
        avg(datediff('minute', sp.join_time, coalesce(sp.leave_time, sm.end_time))) as average_participation_minutes,
        count(distinct sf.feature_name) as features_used_count,
        sum(case when upper(sf.feature_name) like '%SCREEN%SHARE%' then sf.usage_count else 0 end) as screen_share_duration_minutes,
        sum(case when upper(sf.feature_name) like '%RECORD%' then sf.usage_count else 0 end) as recording_duration_minutes,
        sum(case when upper(sf.feature_name) like '%CHAT%' then sf.usage_count else 0 end) as chat_messages_count,
        sum(case when upper(sf.feature_name) like '%FILE%' then sf.usage_count else 0 end) as file_shares_count,
        sum(case when upper(sf.feature_name) like '%BREAKOUT%' then sf.usage_count else 0 end) as breakout_rooms_used,
        sum(case when upper(sf.feature_name) like '%POLL%' then sf.usage_count else 0 end) as polls_conducted
    from source_meetings sm
    left join source_participants sp on sm.meeting_id = sp.meeting_id
    left join source_features sf on sm.meeting_id = sf.meeting_id
    group by sm.meeting_id, sm.host_id, sm.meeting_topic, sm.start_time, sm.end_time, 
             sm.duration_minutes, sm.data_quality_score, sm.source_system
),

meeting_activity_fact as (
    select 
        row_number() over (order by ma.meeting_id) as meeting_activity_id,
        dd.date_id,
        coalesce(dmt.meeting_type_id, 1) as meeting_type_id,
        coalesce(du.user_dim_id, 1) as host_user_dim_id,
        ma.meeting_id,
        date(ma.start_time) as meeting_date,
        ma.start_time as meeting_start_time,
        ma.end_time as meeting_end_time,
        ma.duration_minutes as scheduled_duration_minutes,
        ma.duration_minutes as actual_duration_minutes,
        coalesce(ma.participant_count, 0) as participant_count,
        coalesce(ma.unique_participants, 0) as unique_participants,
        ma.duration_minutes as host_duration_minutes,
        coalesce(ma.total_participant_minutes, 0) as total_participant_minutes,
        coalesce(ma.average_participation_minutes, 0) as average_participation_minutes,
        coalesce(ma.participant_count, 0) as peak_concurrent_participants,
        0 as late_joiners_count, -- To be calculated with more detailed logic
        0 as early_leavers_count, -- To be calculated with more detailed logic
        coalesce(ma.features_used_count, 0) as features_used_count,
        coalesce(ma.screen_share_duration_minutes, 0) as screen_share_duration_minutes,
        coalesce(ma.recording_duration_minutes, 0) as recording_duration_minutes,
        coalesce(ma.chat_messages_count, 0) as chat_messages_count,
        coalesce(ma.file_shares_count, 0) as file_shares_count,
        coalesce(ma.breakout_rooms_used, 0) as breakout_rooms_used,
        coalesce(ma.polls_conducted, 0) as polls_conducted,
        case 
            when ma.participant_count >= 5 and ma.average_participation_minutes >= (ma.duration_minutes * 0.8) then 5.0
            when ma.participant_count >= 3 and ma.average_participation_minutes >= (ma.duration_minutes * 0.6) then 4.0
            when ma.participant_count >= 2 and ma.average_participation_minutes >= (ma.duration_minutes * 0.4) then 3.0
            when ma.participant_count >= 1 and ma.average_participation_minutes >= (ma.duration_minutes * 0.2) then 2.0
            else 1.0
        end as meeting_quality_score,
        case 
            when ma.data_quality_score >= 90 then 5.0
            when ma.data_quality_score >= 80 then 4.0
            when ma.data_quality_score >= 70 then 3.0
            else 2.0
        end as audio_quality_score,
        case 
            when ma.data_quality_score >= 90 then 5.0
            when ma.data_quality_score >= 80 then 4.0
            when ma.data_quality_score >= 70 then 3.0
            else 2.0
        end as video_quality_score,
        0 as connection_issues_count, -- Default value
        case 
            when ma.data_quality_score >= 90 then 5.0
            when ma.data_quality_score >= 80 then 4.0
            when ma.data_quality_score >= 70 then 3.0
            else 2.0
        end as meeting_satisfaction_score,
        current_date as load_date,
        current_date as update_date,
        ma.source_system
    from meeting_aggregates ma
    left join {{ ref('dim_date') }} dd on date(ma.start_time) = dd.date_id
    left join {{ ref('dim_user') }} du on ma.host_id = du.user_id and du.is_current_record = true
    left join {{ ref('dim_meeting_type') }} dmt on (
        case 
            when ma.duration_minutes <= 15 then 'Brief'
            when ma.duration_minutes <= 60 then 'Standard'
            when ma.duration_minutes <= 120 then 'Extended'
            else 'Long'
        end = dmt.duration_category
        and case 
            when hour(ma.start_time) between 6 and 11 then 'Morning'
            when hour(ma.start_time) between 12 and 17 then 'Afternoon'
            when hour(ma.start_time) between 18 and 21 then 'Evening'
            else 'Night'
        end = dmt.time_of_day_category
    )
)

select * from meeting_activity_fact
