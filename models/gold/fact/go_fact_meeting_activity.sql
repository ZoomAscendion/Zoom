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

meeting_metrics as (
    select
        sm.meeting_id,
        sm.host_id,
        sm.meeting_topic,
        sm.start_time,
        sm.end_time,
        sm.duration_minutes,
        date(sm.start_time) as meeting_date,
        count(distinct sp.user_id) as participant_count,
        sum(datediff('minute', sp.join_time, sp.leave_time)) as total_participant_minutes,
        avg(datediff('minute', sp.join_time, sp.leave_time)) as average_participation_minutes,
        count(distinct sf.feature_name) as features_used_count,
        sum(case when upper(sf.feature_name) like '%SCREEN%SHARE%' then sf.usage_count else 0 end) as screen_share_duration_minutes,
        sum(case when upper(sf.feature_name) like '%RECORD%' then sf.usage_count else 0 end) as recording_duration_minutes,
        sum(case when upper(sf.feature_name) like '%CHAT%' then sf.usage_count else 0 end) as chat_messages_count,
        sum(case when upper(sf.feature_name) like '%FILE%' then sf.usage_count else 0 end) as file_shares_count,
        sum(case when upper(sf.feature_name) like '%BREAKOUT%' then 1 else 0 end) as breakout_rooms_used,
        sum(case when upper(sf.feature_name) like '%POLL%' then 1 else 0 end) as polls_conducted,
        sm.data_quality_score,
        sm.source_system
    from source_meetings sm
    left join source_participants sp on sm.meeting_id = sp.meeting_id
    left join source_features sf on sm.meeting_id = sf.meeting_id
    group by 
        sm.meeting_id, sm.host_id, sm.meeting_topic, sm.start_time, 
        sm.end_time, sm.duration_minutes, sm.data_quality_score, sm.source_system
),

meeting_activity_fact as (
    select
        mm.meeting_id,
        dd.date_id as date_id,
        dmt.meeting_type_id as meeting_type_id,
        du.user_dim_id as host_user_dim_id,
        mm.meeting_date,
        mm.start_time as meeting_start_time,
        mm.end_time as meeting_end_time,
        mm.duration_minutes as scheduled_duration_minutes,
        mm.duration_minutes as actual_duration_minutes,
        mm.participant_count,
        mm.participant_count as unique_participants,
        mm.duration_minutes as host_duration_minutes,
        mm.total_participant_minutes,
        mm.average_participation_minutes,
        mm.participant_count as peak_concurrent_participants,
        0 as late_joiners_count,
        0 as early_leavers_count,
        mm.features_used_count,
        mm.screen_share_duration_minutes,
        mm.recording_duration_minutes,
        mm.chat_messages_count,
        mm.file_shares_count,
        mm.breakout_rooms_used,
        mm.polls_conducted,
        case 
            when mm.participant_count >= 5 and mm.average_participation_minutes >= (mm.duration_minutes * 0.8) then 5.0
            when mm.participant_count >= 3 and mm.average_participation_minutes >= (mm.duration_minutes * 0.6) then 4.0
            when mm.participant_count >= 2 and mm.average_participation_minutes >= (mm.duration_minutes * 0.4) then 3.0
            when mm.participant_count >= 1 and mm.average_participation_minutes >= (mm.duration_minutes * 0.2) then 2.0
            else 1.0
        end as meeting_quality_score,
        case 
            when mm.data_quality_score >= 90 then 5.0
            when mm.data_quality_score >= 80 then 4.0
            when mm.data_quality_score >= 70 then 3.0
            else 2.0
        end as audio_quality_score,
        case 
            when mm.data_quality_score >= 90 then 5.0
            when mm.data_quality_score >= 80 then 4.0
            when mm.data_quality_score >= 70 then 3.0
            else 2.0
        end as video_quality_score,
        0 as connection_issues_count,
        case 
            when mm.data_quality_score >= 90 then 5.0
            when mm.data_quality_score >= 80 then 4.0
            when mm.data_quality_score >= 70 then 3.0
            else 2.0
        end as meeting_satisfaction_score,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        mm.source_system
    from meeting_metrics mm
    join {{ ref('go_dim_date') }} dd on mm.meeting_date = dd.date_value
    join {{ ref('go_dim_user') }} du on mm.host_id = du.user_id and du.is_current_record = true
    join {{ ref('go_dim_meeting_type') }} dmt on dmt.meeting_type_id = 1 -- Default meeting type
)

select * from meeting_activity_fact
