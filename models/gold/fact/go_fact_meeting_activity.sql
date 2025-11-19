{{ config(
    materialized='table'
) }}

-- Meeting activity fact table with comprehensive meeting metrics
-- Central fact table for meeting analytics and engagement tracking

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
    WHERE validation_status = 'PASSED'
      AND data_quality_score >= 70
      AND start_time IS NOT NULL
      AND duration_minutes > 0
),

participant_metrics AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count,
        COUNT(DISTINCT user_id) AS unique_participants,
        SUM(DATEDIFF('minute', join_time, COALESCE(leave_time, join_time + INTERVAL '60 minutes'))) AS total_participant_minutes,
        AVG(DATEDIFF('minute', join_time, COALESCE(leave_time, join_time + INTERVAL '60 minutes'))) AS average_participation_minutes,
        COUNT(CASE WHEN join_time > (SELECT MIN(join_time) FROM {{ source('silver', 'si_participants') }} p2 WHERE p2.meeting_id = p1.meeting_id) + INTERVAL '5 minutes' THEN 1 END) AS late_joiners_count,
        COUNT(CASE WHEN leave_time < (SELECT MAX(leave_time) FROM {{ source('silver', 'si_participants') }} p3 WHERE p3.meeting_id = p1.meeting_id) - INTERVAL '5 minutes' THEN 1 END) AS early_leavers_count
    FROM {{ source('silver', 'si_participants') }} p1
    WHERE validation_status = 'PASSED'
    GROUP BY meeting_id
),

feature_metrics AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT feature_name) AS features_used_count,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN usage_count ELSE 0 END) AS screen_share_duration_minutes,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%RECORD%' THEN usage_count ELSE 0 END) AS recording_duration_minutes,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%CHAT%' THEN usage_count ELSE 0 END) AS chat_messages_count,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%FILE%' OR UPPER(feature_name) LIKE '%SHARE%' THEN usage_count ELSE 0 END) AS file_shares_count,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN usage_count ELSE 0 END) AS breakout_rooms_used,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%POLL%' THEN usage_count ELSE 0 END) AS polls_conducted
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = 'PASSED'
    GROUP BY meeting_id
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
        COALESCE(pm.participant_count, 0) AS participant_count,
        COALESCE(pm.unique_participants, 0) AS unique_participants,
        sm.duration_minutes AS host_duration_minutes,
        COALESCE(pm.total_participant_minutes, 0) AS total_participant_minutes,
        COALESCE(pm.average_participation_minutes, 0) AS average_participation_minutes,
        COALESCE(pm.participant_count, 0) AS peak_concurrent_participants,  -- Simplified
        COALESCE(pm.late_joiners_count, 0) AS late_joiners_count,
        COALESCE(pm.early_leavers_count, 0) AS early_leavers_count,
        COALESCE(fm.features_used_count, 0) AS features_used_count,
        COALESCE(fm.screen_share_duration_minutes, 0) AS screen_share_duration_minutes,
        COALESCE(fm.recording_duration_minutes, 0) AS recording_duration_minutes,
        COALESCE(fm.chat_messages_count, 0) AS chat_messages_count,
        COALESCE(fm.file_shares_count, 0) AS file_shares_count,
        COALESCE(fm.breakout_rooms_used, 0) AS breakout_rooms_used,
        COALESCE(fm.polls_conducted, 0) AS polls_conducted,
        -- Meeting quality score calculation
        CASE 
            WHEN COALESCE(pm.participant_count, 0) >= 5 AND COALESCE(pm.average_participation_minutes, 0) >= (sm.duration_minutes * 0.8) THEN 5.0
            WHEN COALESCE(pm.participant_count, 0) >= 3 AND COALESCE(pm.average_participation_minutes, 0) >= (sm.duration_minutes * 0.6) THEN 4.0
            WHEN COALESCE(pm.participant_count, 0) >= 2 AND COALESCE(pm.average_participation_minutes, 0) >= (sm.duration_minutes * 0.4) THEN 3.0
            WHEN COALESCE(pm.participant_count, 0) >= 1 AND COALESCE(pm.average_participation_minutes, 0) >= (sm.duration_minutes * 0.2) THEN 2.0
            ELSE 1.0
        END AS meeting_quality_score,
        4.5 AS audio_quality_score,  -- Default value
        4.5 AS video_quality_score,  -- Default value
        0 AS connection_issues_count,  -- Default value
        -- Meeting satisfaction based on engagement
        CASE 
            WHEN COALESCE(pm.participant_count, 0) >= 3 AND COALESCE(fm.features_used_count, 0) >= 2 THEN 5.0
            WHEN COALESCE(pm.participant_count, 0) >= 2 AND COALESCE(fm.features_used_count, 0) >= 1 THEN 4.0
            WHEN COALESCE(pm.participant_count, 0) >= 1 THEN 3.0
            ELSE 2.0
        END AS meeting_satisfaction_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        sm.source_system
    FROM source_meetings sm
    LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(sm.start_time) = dd.date_value
    LEFT JOIN {{ ref('go_dim_user') }} du ON sm.host_id = du.user_id AND du.is_current_record = TRUE
    LEFT JOIN {{ ref('go_dim_meeting_type') }} dmt ON (
        CASE 
            WHEN sm.duration_minutes <= 15 THEN 'Quick Sync'
            WHEN sm.duration_minutes <= 60 THEN 'Standard Meeting'
            WHEN sm.duration_minutes <= 120 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END = dmt.meeting_category
        AND CASE 
            WHEN HOUR(sm.start_time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(sm.start_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(sm.start_time) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END = dmt.time_of_day_category
    )
    LEFT JOIN participant_metrics pm ON sm.meeting_id = pm.meeting_id
    LEFT JOIN feature_metrics fm ON sm.meeting_id = fm.meeting_id
)

SELECT * FROM meeting_activity_facts
