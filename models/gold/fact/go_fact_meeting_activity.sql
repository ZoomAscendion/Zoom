{{ config(
    materialized='table',
    unique_key='meeting_activity_id'
) }}

with source_meetings as (
    select 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        data_quality_score,
        source_system
    from {{ source('silver', 'si_meetings') }}
    where validation_status = 'PASSED'
),

participant_metrics as (
    select 
        meeting_id,
        count(distinct user_id) as participant_count,
        sum(datediff('minute', join_time, leave_time)) as total_participant_minutes,
        avg(datediff('minute', join_time, leave_time)) as average_participation_minutes,
        max(case when join_time > dateadd('minute', 5, 
            (select start_time from source_meetings sm where sm.meeting_id = sp.meeting_id)) 
            then 1 else 0 end) as late_joiners_count,
        max(case when leave_time < dateadd('minute', -5, 
            (select end_time from source_meetings sm where sm.meeting_id = sp.meeting_id)) 
            then 1 else 0 end) as early_leavers_count
    from {{ source('silver', 'si_participants') }} sp
    where validation_status = 'PASSED'
    group by meeting_id
),

feature_metrics as (
    select 
        meeting_id,
        count(distinct feature_name) as features_used_count,
        sum(case when upper(feature_name) like '%SCREEN%SHARE%' then usage_count else 0 end) as screen_share_duration_minutes,
        sum(case when upper(feature_name) like '%RECORD%' then usage_count else 0 end) as recording_duration_minutes,
        sum(case when upper(feature_name) like '%CHAT%' then usage_count else 0 end) as chat_messages_count,
        sum(case when upper(feature_name) like '%FILE%' then usage_count else 0 end) as file_shares_count,
        sum(case when upper(feature_name) like '%BREAKOUT%' then usage_count else 0 end) as breakout_rooms_used,
        sum(case when upper(feature_name) like '%POLL%' then usage_count else 0 end) as polls_conducted
    from {{ source('silver', 'si_feature_usage') }} fu
    where validation_status = 'PASSED'
    group by meeting_id
),

meeting_activity_fact as (
    select 
        row_number() over (order by sm.meeting_id) as meeting_activity_id,
        dd.date_id as date_id,
        dmt.meeting_type_id as meeting_type_id,
        du.user_dim_id as host_user_dim_id,
        sm.meeting_id,
        date(sm.start_time) as meeting_date,
        sm.start_time as meeting_start_time,
        sm.end_time as meeting_end_time,
        sm.duration_minutes as scheduled_duration_minutes,
        sm.duration_minutes as actual_duration_minutes,
        coalesce(pm.participant_count, 0) as participant_count,
        coalesce(pm.participant_count, 0) as unique_participants,
        sm.duration_minutes as host_duration_minutes,
        coalesce(pm.total_participant_minutes, 0) as total_participant_minutes,
        coalesce(pm.average_participation_minutes, 0) as average_participation_minutes,
        coalesce(pm.participant_count, 0) as peak_concurrent_participants,
        coalesce(pm.late_joiners_count, 0) as late_joiners_count,
        coalesce(pm.early_leavers_count, 0) as early_leavers_count,
        coalesce(fm.features_used_count, 0) as features_used_count,
        coalesce(fm.screen_share_duration_minutes, 0) as screen_share_duration_minutes,
        coalesce(fm.recording_duration_minutes, 0) as recording_duration_minutes,
        coalesce(fm.chat_messages_count, 0) as chat_messages_count,
        coalesce(fm.file_shares_count, 0) as file_shares_count,
        coalesce(fm.breakout_rooms_used, 0) as breakout_rooms_used,
        coalesce(fm.polls_conducted, 0) as polls_conducted,
        case 
            when coalesce(pm.participant_count, 0) >= 5 and coalesce(pm.average_participation_minutes, 0) >= (sm.duration_minutes * 0.8) then 5.0
            when coalesce(pm.participant_count, 0) >= 3 and coalesce(pm.average_participation_minutes, 0) >= (sm.duration_minutes * 0.6) then 4.0
            when coalesce(pm.participant_count, 0) >= 2 and coalesce(pm.average_participation_minutes, 0) >= (sm.duration_minutes * 0.4) then 3.0
            when coalesce(pm.participant_count, 0) >= 1 and coalesce(pm.average_participation_minutes, 0) >= (sm.duration_minutes * 0.2) then 2.0
            else 1.0
        end as meeting_quality_score,
        5.0 as audio_quality_score,
        5.0 as video_quality_score,
        0 as connection_issues_count,
        case 
            when coalesce(pm.participant_count, 0) >= 5 then 5.0
            when coalesce(pm.participant_count, 0) >= 3 then 4.0
            when coalesce(pm.participant_count, 0) >= 2 then 3.0
            else 2.0
        end as meeting_satisfaction_score,
        current_date as load_date,
        current_date as update_date,
        sm.source_system
    from source_meetings sm
    left join participant_metrics pm on sm.meeting_id = pm.meeting_id
    left join feature_metrics fm on sm.meeting_id = fm.meeting_id
    left join {{ ref('go_dim_date') }} dd on date(sm.start_time) = dd.date_value
    left join {{ ref('go_dim_meeting_type') }} dmt on sm.meeting_id = dmt.meeting_type_id::varchar
    left join {{ ref('go_dim_user') }} du on sm.host_id = du.user_id
)

select * from meeting_activity_fact
