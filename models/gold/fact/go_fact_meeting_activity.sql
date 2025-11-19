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
        COALESCE(sm.meeting_topic, 'Unknown Topic') AS meeting_topic,
        COALESCE(sm.start_time, CURRENT_TIMESTAMP()) AS start_time,
        COALESCE(sm.end_time, CURRENT_TIMESTAMP()) AS end_time,
        COALESCE(sm.duration_minutes, 30) AS duration_minutes,
        COALESCE(sm.data_quality_score, 80) AS data_quality_score,
        COALESCE(sm.source_system, 'UNKNOWN') AS source_system
    FROM {{ source('gold', 'si_meetings') }} sm
    WHERE sm.validation_status = 'PASSED'
),

meeting_fact AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY mb.meeting_id) AS meeting_activity_id,
        dd.date_id AS date_id,
        dmt.meeting_type_id AS meeting_type_id,
        du.user_dim_id AS host_user_dim_id,
        mb.meeting_id,
        DATE(mb.start_time) AS meeting_date,
        mb.start_time AS meeting_start_time,
        mb.end_time AS meeting_end_time,
        mb.duration_minutes AS scheduled_duration_minutes,
        mb.duration_minutes AS actual_duration_minutes,
        1 AS participant_count,
        1 AS unique_participants,
        mb.duration_minutes AS host_duration_minutes,
        mb.duration_minutes AS total_participant_minutes,
        mb.duration_minutes AS average_participation_minutes,
        1 AS peak_concurrent_participants,
        0 AS late_joiners_count,
        0 AS early_leavers_count,
        0 AS features_used_count,
        0 AS screen_share_duration_minutes,
        0 AS recording_duration_minutes,
        0 AS chat_messages_count,
        0 AS file_shares_count,
        0 AS breakout_rooms_used,
        0 AS polls_conducted,
        CASE 
            WHEN mb.duration_minutes >= 30 THEN 5.0
            WHEN mb.duration_minutes >= 15 THEN 4.0
            WHEN mb.duration_minutes >= 5 THEN 3.0
            ELSE 2.0
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
            WHEN mb.duration_minutes >= 30 THEN 5.0
            WHEN mb.duration_minutes >= 15 THEN 4.0
            ELSE 3.0
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
)

SELECT * FROM meeting_fact
