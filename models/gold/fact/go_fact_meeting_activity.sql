{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_FACT_MEETING_ACTIVITY', run_started_at]) }}', 'GO_FACT_MEETING_ACTIVITY_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_MEETINGS', 'GO_FACT_MEETING_ACTIVITY', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_FACT_MEETING_ACTIVITY', run_started_at]) }}'"
) }}

-- Meeting activity fact table transformation
WITH meeting_base AS (
    SELECT 
        sm.meeting_id,
        sm.host_id,
        sm.meeting_topic,
        sm.start_time,
        sm.end_time,
        sm.duration_minutes,
        sm.data_quality_score,
        sm.source_system
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE sm.validation_status = 'PASSED'
),

participant_metrics AS (
    SELECT 
        sp.meeting_id,
        COUNT(DISTINCT sp.user_id) AS participant_count,
        SUM(DATEDIFF('minute', sp.join_time, sp.leave_time)) AS total_participant_minutes,
        AVG(DATEDIFF('minute', sp.join_time, sp.leave_time)) AS average_participation_minutes,
        COUNT(CASE WHEN sp.join_time > DATEADD('minute', 5, mb.start_time) THEN 1 END) AS late_joiners_count,
        COUNT(CASE WHEN sp.leave_time < DATEADD('minute', -5, mb.end_time) THEN 1 END) AS early_leavers_count
    FROM {{ source('silver', 'si_participants') }} sp
    JOIN meeting_base mb ON sp.meeting_id = mb.meeting_id
    WHERE sp.validation_status = 'PASSED'
    GROUP BY sp.meeting_id
),

feature_metrics AS (
    SELECT 
        sf.meeting_id,
        COUNT(DISTINCT sf.feature_name) AS features_used_count,
        SUM(CASE WHEN UPPER(sf.feature_name) LIKE '%SCREEN%SHARE%' THEN sf.usage_count ELSE 0 END) AS screen_share_duration_minutes,
        SUM(CASE WHEN UPPER(sf.feature_name) LIKE '%RECORD%' THEN sf.usage_count ELSE 0 END) AS recording_duration_minutes,
        SUM(CASE WHEN UPPER(sf.feature_name) LIKE '%CHAT%' THEN sf.usage_count ELSE 0 END) AS chat_messages_count,
        SUM(CASE WHEN UPPER(sf.feature_name) LIKE '%FILE%' THEN sf.usage_count ELSE 0 END) AS file_shares_count,
        SUM(CASE WHEN UPPER(sf.feature_name) LIKE '%BREAKOUT%' THEN sf.usage_count ELSE 0 END) AS breakout_rooms_used,
        SUM(CASE WHEN UPPER(sf.feature_name) LIKE '%POLL%' THEN sf.usage_count ELSE 0 END) AS polls_conducted
    FROM {{ source('silver', 'si_feature_usage') }} sf
    WHERE sf.validation_status = 'PASSED'
    GROUP BY sf.meeting_id
),

meeting_fact AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['mb.meeting_id']) }} AS meeting_activity_id,
        dd.date_id AS date_id,
        dmt.meeting_type_id AS meeting_type_id,
        du.user_dim_id AS host_user_dim_id,
        mb.meeting_id,
        DATE(mb.start_time) AS meeting_date,
        mb.start_time AS meeting_start_time,
        mb.end_time AS meeting_end_time,
        mb.duration_minutes AS scheduled_duration_minutes,
        mb.duration_minutes AS actual_duration_minutes,
        COALESCE(pm.participant_count, 0) AS participant_count,
        COALESCE(pm.participant_count, 0) AS unique_participants,
        mb.duration_minutes AS host_duration_minutes,
        COALESCE(pm.total_participant_minutes, 0) AS total_participant_minutes,
        COALESCE(pm.average_participation_minutes, 0) AS average_participation_minutes,
        COALESCE(pm.participant_count, 0) AS peak_concurrent_participants,
        COALESCE(pm.late_joiners_count, 0) AS late_joiners_count,
        COALESCE(pm.early_leavers_count, 0) AS early_leavers_count,
        COALESCE(fm.features_used_count, 0) AS features_used_count,
        COALESCE(fm.screen_share_duration_minutes, 0) AS screen_share_duration_minutes,
        COALESCE(fm.recording_duration_minutes, 0) AS recording_duration_minutes,
        COALESCE(fm.chat_messages_count, 0) AS chat_messages_count,
        COALESCE(fm.file_shares_count, 0) AS file_shares_count,
        COALESCE(fm.breakout_rooms_used, 0) AS breakout_rooms_used,
        COALESCE(fm.polls_conducted, 0) AS polls_conducted,
        CASE 
            WHEN COALESCE(pm.participant_count, 0) >= 5 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.duration_minutes * 0.8) THEN 5.0
            WHEN COALESCE(pm.participant_count, 0) >= 3 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.duration_minutes * 0.6) THEN 4.0
            WHEN COALESCE(pm.participant_count, 0) >= 2 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.duration_minutes * 0.4) THEN 3.0
            WHEN COALESCE(pm.participant_count, 0) >= 1 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.duration_minutes * 0.2) THEN 2.0
            ELSE 1.0
        END AS meeting_quality_score,
        CASE 
            WHEN mb.data_quality_score >= 90 THEN 5.0
            WHEN mb.data_quality_score >= 80 THEN 4.0
            WHEN mb.data_quality_score >= 70 THEN 3.0
            ELSE 2.0
        END AS audio_quality_score,
        CASE 
            WHEN mb.data_quality_score >= 90 THEN 5.0
            WHEN mb.data_quality_score >= 80 THEN 4.0
            WHEN mb.data_quality_score >= 70 THEN 3.0
            ELSE 2.0
        END AS video_quality_score,
        0 AS connection_issues_count,
        CASE 
            WHEN COALESCE(pm.participant_count, 0) >= 5 AND mb.duration_minutes >= 30 THEN 5.0
            WHEN COALESCE(pm.participant_count, 0) >= 3 AND mb.duration_minutes >= 15 THEN 4.0
            WHEN COALESCE(pm.participant_count, 0) >= 2 THEN 3.0
            WHEN COALESCE(pm.participant_count, 0) >= 1 THEN 2.0
            ELSE 1.0
        END AS meeting_satisfaction_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        mb.source_system
    FROM meeting_base mb
    LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(mb.start_time) = dd.date_value
    LEFT JOIN {{ ref('go_dim_user') }} du ON mb.host_id = du.user_id AND du.is_current_record = TRUE
    LEFT JOIN {{ ref('go_dim_meeting_type') }} dmt ON (
        CASE 
            WHEN mb.duration_minutes <= 15 THEN 'Quick Sync'
            WHEN mb.duration_minutes <= 60 THEN 'Standard Meeting'
            WHEN mb.duration_minutes <= 120 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END = dmt.meeting_category
    )
    LEFT JOIN participant_metrics pm ON mb.meeting_id = pm.meeting_id
    LEFT JOIN feature_metrics fm ON mb.meeting_id = fm.meeting_id
)

SELECT * FROM meeting_fact
