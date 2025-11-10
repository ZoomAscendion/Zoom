{{ config(
    materialized='table',
    tags=['fact'],
    cluster_by=['MEETING_DATE']
) }}

-- Meeting activity fact table with comprehensive engagement metrics
-- Transforms Silver meeting data with participant and feature analytics

WITH meeting_base AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        m.meeting_topic,
        m.start_time,
        m.end_time,
        m.duration_minutes,
        m.source_system
    FROM {{ source('silver', 'si_meetings') }} m
    WHERE m.validation_status = 'PASSED'
      AND m.data_quality_score >= 80
      AND m.duration_minutes > 0
),

participant_metrics AS (
    SELECT 
        p.meeting_id,
        COUNT(*) AS participant_count,
        COUNT(DISTINCT p.user_id) AS unique_participants,
        SUM(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, mb.end_time))) AS total_join_time_minutes,
        AVG(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, mb.end_time))) AS avg_participation_minutes
    FROM {{ source('silver', 'si_participants') }} p
    JOIN meeting_base mb ON p.meeting_id = mb.meeting_id
    WHERE p.validation_status = 'PASSED'
      AND p.data_quality_score >= 80
    GROUP BY p.meeting_id
),

feature_metrics AS (
    SELECT 
        fu.meeting_id,
        COUNT(DISTINCT fu.feature_name) AS features_used_count,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%SCREEN%' THEN fu.usage_count * 5 ELSE 0 END) AS screen_share_duration,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%RECORD%' THEN fu.usage_count * 10 ELSE 0 END) AS recording_duration,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%CHAT%' THEN fu.usage_count ELSE 0 END) AS chat_messages_count,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%FILE%' THEN fu.usage_count ELSE 0 END) AS file_shares_count,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%BREAKOUT%' THEN 1 ELSE 0 END) AS breakout_rooms_used,
        COUNT(CASE WHEN UPPER(fu.feature_name) LIKE '%VIDEO%' THEN 1 END) AS video_features_used
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.validation_status = 'PASSED'
      AND fu.data_quality_score >= 80
    GROUP BY fu.meeting_id
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY mb.start_time, mb.meeting_id) AS meeting_activity_id,
    
    -- Date and time dimensions
    DATE(mb.start_time) AS meeting_date,
    mb.start_time AS meeting_start_time,
    mb.end_time AS meeting_end_time,
    
    -- Duration metrics
    mb.duration_minutes AS scheduled_duration_minutes,
    mb.duration_minutes AS actual_duration_minutes,
    
    -- Participant metrics
    COALESCE(pm.participant_count, 0) AS participant_count,
    COALESCE(pm.unique_participants, 0) AS unique_participants,
    COALESCE(pm.total_join_time_minutes, 0) AS total_join_time_minutes,
    COALESCE(pm.avg_participation_minutes, 0) AS average_participation_minutes,
    
    -- Engagement score calculation (1-10 scale)
    CASE 
        WHEN pm.avg_participation_minutes > 0 AND mb.duration_minutes > 0 THEN
            LEAST(10.0, (pm.avg_participation_minutes / mb.duration_minutes) * 10)
        ELSE 0
    END AS participant_engagement_score,
    
    -- Overall meeting quality score
    CASE 
        WHEN pm.participant_count > 0 THEN
            LEAST(10.0, 
                (CASE WHEN pm.avg_participation_minutes / NULLIF(mb.duration_minutes, 0) > 0.7 THEN 8.0
                      WHEN pm.avg_participation_minutes / NULLIF(mb.duration_minutes, 0) > 0.5 THEN 6.0
                      ELSE 4.0 END +
                 CASE WHEN fm.features_used_count > 5 THEN 2.0
                      WHEN fm.features_used_count > 2 THEN 1.0
                      ELSE 0.5 END) / 2.0
            )
        ELSE 5.0
    END AS meeting_quality_score,
    
    -- Audio quality estimation
    CASE 
        WHEN mb.duration_minutes > 60 AND pm.participant_count > 10 THEN 7.5
        WHEN mb.duration_minutes > 30 THEN 8.5
        ELSE 9.0
    END AS audio_quality_score,
    
    -- Video quality estimation
    CASE 
        WHEN fm.video_features_used > 0 THEN 8.0
        ELSE 6.0
    END AS video_quality_score,
    
    -- Connection stability score
    CASE 
        WHEN pm.avg_participation_minutes / NULLIF(mb.duration_minutes, 0) > 0.8 THEN 9.0
        WHEN pm.avg_participation_minutes / NULLIF(mb.duration_minutes, 0) > 0.6 THEN 7.5
        ELSE 6.0
    END AS connection_stability_score,
    
    -- Feature usage metrics
    COALESCE(fm.features_used_count, 0) AS features_used_count,
    COALESCE(fm.screen_share_duration, 0) AS screen_share_duration_minutes,
    COALESCE(fm.recording_duration, 0) AS recording_duration_minutes,
    COALESCE(fm.chat_messages_count, 0) AS chat_messages_count,
    COALESCE(fm.file_shares_count, 0) AS file_shares_count,
    COALESCE(fm.breakout_rooms_used, 0) AS breakout_rooms_used,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    mb.source_system
    
FROM meeting_base mb
LEFT JOIN participant_metrics pm ON mb.meeting_id = pm.meeting_id
LEFT JOIN feature_metrics fm ON mb.meeting_id = fm.meeting_id
ORDER BY mb.start_time, mb.meeting_id
