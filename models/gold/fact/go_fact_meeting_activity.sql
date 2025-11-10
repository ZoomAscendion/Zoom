{{ config(
    materialized='table',
    cluster_by=['MEETING_DATE'],
    tags=['fact', 'meeting']
) }}

-- Central fact table capturing comprehensive meeting activities and engagement metrics
-- Combines data from meetings, participants, and feature usage

WITH source_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        source_system,
        validation_status,
        data_quality_score
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
        AND duration_minutes > 0
),

participant_metrics AS (
    SELECT 
        p.meeting_id,
        COUNT(*) AS participant_count,
        COUNT(DISTINCT p.user_id) AS unique_participants,
        SUM(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, m.end_time))) AS total_join_time_minutes,
        AVG(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, m.end_time))) AS avg_participation_minutes,
        
        -- Calculate engagement factor
        CASE 
            WHEN AVG(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, m.end_time))) / NULLIF(m.duration_minutes, 0) > 0.8 THEN 9.0
            WHEN AVG(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, m.end_time))) / NULLIF(m.duration_minutes, 0) > 0.6 THEN 7.0
            WHEN AVG(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, m.end_time))) / NULLIF(m.duration_minutes, 0) > 0.4 THEN 5.0
            ELSE 3.0
        END AS engagement_factor
        
    FROM {{ source('silver', 'si_participants') }} p
    JOIN source_meetings m ON p.meeting_id = m.meeting_id
    WHERE p.validation_status = {{ var('validation_status_filter') }}
        AND p.data_quality_score >= {{ var('data_quality_threshold') }}
    GROUP BY p.meeting_id, m.duration_minutes
),

feature_metrics AS (
    SELECT 
        fu.meeting_id,
        COUNT(DISTINCT fu.feature_name) AS features_used_count,
        
        -- Feature-specific duration calculations
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%SCREEN%' THEN fu.usage_count * 5 ELSE 0 END) AS screen_share_duration_minutes,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%RECORD%' THEN fu.usage_count * 10 ELSE 0 END) AS recording_duration_minutes,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%CHAT%' THEN fu.usage_count ELSE 0 END) AS chat_messages_count,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%FILE%' OR UPPER(fu.feature_name) LIKE '%SHARE%' THEN fu.usage_count ELSE 0 END) AS file_shares_count,
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%BREAKOUT%' THEN 1 ELSE 0 END) AS breakout_rooms_used,
        
        -- Video feature indicator
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%VIDEO%' THEN 1 ELSE 0 END) AS video_features_used,
        
        -- Feature complexity factor
        CASE 
            WHEN COUNT(DISTINCT fu.feature_name) > 5 THEN 9.0
            WHEN COUNT(DISTINCT fu.feature_name) > 3 THEN 7.0
            WHEN COUNT(DISTINCT fu.feature_name) > 1 THEN 5.0
            ELSE 3.0
        END AS feature_factor
        
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.validation_status = {{ var('validation_status_filter') }}
        AND fu.data_quality_score >= {{ var('data_quality_threshold') }}
    GROUP BY fu.meeting_id
),

meeting_activity_calculations AS (
    SELECT 
        m.meeting_id,
        DATE(m.start_time) AS meeting_date,
        m.start_time AS meeting_start_time,
        m.end_time AS meeting_end_time,
        m.duration_minutes AS scheduled_duration_minutes,
        m.duration_minutes AS actual_duration_minutes,
        
        -- Participant metrics
        COALESCE(pm.participant_count, 0) AS participant_count,
        COALESCE(pm.unique_participants, 0) AS unique_participants,
        COALESCE(pm.total_join_time_minutes, 0) AS total_join_time_minutes,
        COALESCE(pm.avg_participation_minutes, 0) AS average_participation_minutes,
        
        -- Engagement score calculation
        CASE 
            WHEN pm.avg_participation_minutes > 0 AND m.duration_minutes > 0 THEN
                LEAST(10.0, (pm.avg_participation_minutes / m.duration_minutes) * 10)
            ELSE 0
        END AS participant_engagement_score,
        
        -- Overall meeting quality score
        CASE 
            WHEN pm.participant_count > 0 THEN
                (COALESCE(pm.engagement_factor, 5.0) + COALESCE(fm.feature_factor, 5.0)) / 2.0
            ELSE 5.0
        END AS meeting_quality_score,
        
        -- Audio quality estimation
        CASE 
            WHEN m.duration_minutes > 60 AND pm.participant_count > 10 THEN 7.5
            WHEN m.duration_minutes > 30 AND pm.participant_count > 5 THEN 8.0
            WHEN m.duration_minutes > 15 THEN 8.5
            ELSE 9.0
        END AS audio_quality_score,
        
        -- Video quality estimation
        CASE 
            WHEN fm.video_features_used > 0 THEN 8.0
            ELSE 6.0
        END AS video_quality_score,
        
        -- Connection stability based on participant retention
        CASE 
            WHEN pm.avg_participation_minutes / NULLIF(m.duration_minutes, 0) > 0.9 THEN 9.5
            WHEN pm.avg_participation_minutes / NULLIF(m.duration_minutes, 0) > 0.8 THEN 9.0
            WHEN pm.avg_participation_minutes / NULLIF(m.duration_minutes, 0) > 0.6 THEN 7.5
            WHEN pm.avg_participation_minutes / NULLIF(m.duration_minutes, 0) > 0.4 THEN 6.0
            ELSE 5.0
        END AS connection_stability_score,
        
        -- Feature usage metrics
        COALESCE(fm.features_used_count, 0) AS features_used_count,
        COALESCE(fm.screen_share_duration_minutes, 0) AS screen_share_duration_minutes,
        COALESCE(fm.recording_duration_minutes, 0) AS recording_duration_minutes,
        COALESCE(fm.chat_messages_count, 0) AS chat_messages_count,
        COALESCE(fm.file_shares_count, 0) AS file_shares_count,
        COALESCE(fm.breakout_rooms_used, 0) AS breakout_rooms_used,
        
        -- Metadata
        m.source_system
        
    FROM source_meetings m
    LEFT JOIN participant_metrics pm ON m.meeting_id = pm.meeting_id
    LEFT JOIN feature_metrics fm ON m.meeting_id = fm.meeting_id
),

final_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY meeting_start_time) AS meeting_activity_id,
        meeting_date,
        meeting_start_time,
        meeting_end_time,
        scheduled_duration_minutes,
        actual_duration_minutes,
        participant_count,
        unique_participants,
        total_join_time_minutes,
        average_participation_minutes,
        participant_engagement_score,
        meeting_quality_score,
        audio_quality_score,
        video_quality_score,
        connection_stability_score,
        features_used_count,
        screen_share_duration_minutes,
        recording_duration_minutes,
        chat_messages_count,
        file_shares_count,
        breakout_rooms_used,
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
        
    FROM meeting_activity_calculations
)

SELECT * FROM final_fact
ORDER BY meeting_date DESC, meeting_start_time DESC
