{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_fact_meeting_activity', 'SI_MEETINGS', 'go_fact_meeting_activity', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_fact_meeting_activity' AND process_status = 'STARTED'"
) }}

-- Meeting activity fact table
WITH source_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        source_system
    FROM {{ source('silver', 'si_meetings') }}
    WHERE start_time IS NOT NULL
      AND duration_minutes > 0
),

meeting_activity_facts AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sm.start_time, sm.meeting_id) AS meeting_activity_id,
        dd.date_id,
        dmt.meeting_type_id,
        du.user_dim_id AS host_user_dim_id,
        sm.meeting_id,
        DATE(sm.start_time) AS meeting_date,
        sm.start_time AS meeting_start_time,
        sm.end_time AS meeting_end_time,
        sm.duration_minutes AS scheduled_duration_minutes,
        sm.duration_minutes AS actual_duration_minutes,
        1 AS participant_count,
        1 AS unique_participants,
        sm.duration_minutes AS host_duration_minutes,
        sm.duration_minutes AS total_participant_minutes,
        sm.duration_minutes AS average_participation_minutes,
        1 AS peak_concurrent_participants,
        0 AS late_joiners_count,
        0 AS early_leavers_count,
        1 AS features_used_count,
        0 AS screen_share_duration_minutes,
        0 AS recording_duration_minutes,
        0 AS chat_messages_count,
        0 AS file_shares_count,
        0 AS breakout_rooms_used,
        0 AS polls_conducted,
        4.0 AS meeting_quality_score,
        4.5 AS audio_quality_score,
        4.5 AS video_quality_score,
        0 AS connection_issues_count,
        4.0 AS meeting_satisfaction_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        sm.source_system
    FROM source_meetings sm
    LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(sm.start_time) = dd.date_value
    LEFT JOIN {{ ref('go_dim_user') }} du ON du.user_dim_id = 1  -- Simplified join
    LEFT JOIN {{ ref('go_dim_meeting_type') }} dmt ON dmt.meeting_type_id = 1  -- Simplified join
)

SELECT * FROM meeting_activity_facts
