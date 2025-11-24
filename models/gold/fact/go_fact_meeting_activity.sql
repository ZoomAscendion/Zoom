{{ config(
    materialized='table'
) }}

with meetings as (
    select 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        data_quality_score,
        source_system,
        validation_status
    from {{ source('silver', 'si_meetings') }}
    where validation_status = 'PASSED'
),

participants as (
    select 
        meeting_id,
        count(distinct user_id) as participant_count,
        sum(datediff('minute', join_time, leave_time)) as total_participant_minutes,
        avg(datediff('minute', join_time, leave_time)) as average_participation_minutes
    from {{ source('silver', 'si_participants') }}
    where validation_status = 'PASSED'
    group by meeting_id
),

feature_usage as (
    select 
        meeting_id,
        count(distinct feature_name) as features_used_count,
        sum(case when upper(feature_name) like '%SCREEN%SHARE%' then usage_count else 0 end) as screen_share_duration_minutes,
        sum(case when upper(feature_name) like '%RECORD%' then usage_count else 0 end) as recording_duration_minutes,
        sum(case when upper(feature_name) like '%CHAT%' then usage_count else 0 end) as chat_messages_count
    from {{ source('silver', 'si_feature_usage') }}
    where validation_status = 'PASSED'
    group by meeting_id
),

transformed as (
    select
        m.meeting_id,
        date(m.start_time) as meeting_date,
        m.start_time as meeting_start_time,
        m.end_time as meeting_end_time,
        m.duration_minutes as scheduled_duration_minutes,
        m.duration_minutes as actual_duration_minutes,
        coalesce(p.participant_count, 0) as participant_count,
        coalesce(p.participant_count, 0) as unique_participants,
        m.duration_minutes as host_duration_minutes,
        coalesce(p.total_participant_minutes, 0) as total_participant_minutes,
        coalesce(p.average_participation_minutes, 0) as average_participation_minutes,
        0 as peak_concurrent_participants,
        0 as late_joiners_count,
        0 as early_leavers_count,
        coalesce(f.features_used_count, 0) as features_used_count,
        coalesce(f.screen_share_duration_minutes, 0) as screen_share_duration_minutes,
        coalesce(f.recording_duration_minutes, 0) as recording_duration_minutes,
        coalesce(f.chat_messages_count, 0) as chat_messages_count,
        0 as file_shares_count,
        0 as breakout_rooms_used,
        0 as polls_conducted,
        case 
            when coalesce(p.participant_count, 0) >= 5 and coalesce(p.average_participation_minutes, 0) >= (m.duration_minutes * 0.8) then 5.0
            when coalesce(p.participant_count, 0) >= 3 and coalesce(p.average_participation_minutes, 0) >= (m.duration_minutes * 0.6) then 4.0
            when coalesce(p.participant_count, 0) >= 2 and coalesce(p.average_participation_minutes, 0) >= (m.duration_minutes * 0.4) then 3.0
            when coalesce(p.participant_count, 0) >= 1 and coalesce(p.average_participation_minutes, 0) >= (m.duration_minutes * 0.2) then 2.0
            else 1.0
        end as meeting_quality_score,
        case 
            when m.data_quality_score >= 90 then 5.0
            when m.data_quality_score >= 80 then 4.0
            when m.data_quality_score >= 70 then 3.0
            else 2.0
        end as audio_quality_score,
        case 
            when m.data_quality_score >= 90 then 5.0
            when m.data_quality_score >= 80 then 4.0
            when m.data_quality_score >= 70 then 3.0
            else 2.0
        end as video_quality_score,
        0 as connection_issues_count,
        case 
            when m.data_quality_score >= 90 then 5.0
            when m.data_quality_score >= 80 then 4.0
            when m.data_quality_score >= 70 then 3.0
            else 2.0
        end as meeting_satisfaction_score,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        m.source_system
    from meetings m
    left join participants p on m.meeting_id = p.meeting_id
    left join feature_usage f on m.meeting_id = f.meeting_id
)

select * from transformed
