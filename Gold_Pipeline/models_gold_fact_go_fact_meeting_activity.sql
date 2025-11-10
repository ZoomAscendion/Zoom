/*
  go_fact_meeting_activity.sql
  Zoom Platform Analytics System - Meeting Activity Fact Table
  
  Author: Data Engineering Team
  Description: Central fact table capturing comprehensive meeting activities and engagement metrics
  
  This model creates detailed meeting activity facts with participant engagement,
  quality scores, and feature usage metrics.
*/

{{ config(
    materialized='table',
    tags=['fact', 'meeting_activity'],
    cluster_by=['meeting_date']
) }}

-- Base meeting data with quality filters
WITH base_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
        AND duration_minutes > 0
        AND start_time IS NOT NULL
        AND end_time IS NOT NULL
),

-- Participant metrics per meeting
participant_metrics AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count,
        COUNT(DISTINCT participant_id) AS unique_participants,
        
        -- Calculate total participation time
        SUM(
            CASE 
                WHEN join_time IS NOT NULL AND leave_time IS NOT NULL 
                THEN DATEDIFF('minute', join_time, leave_time)
                ELSE 0
            END
        ) AS total_join_time_minutes,
        
        -- Average participation time per participant
        AVG(
            CASE 
                WHEN join_time IS NOT NULL AND leave_time IS NOT NULL 
                THEN DATEDIFF('minute', join_time, leave_time)
                ELSE NULL
            END
        ) AS average_participation_minutes,
        
        -- Engagement metrics
        COUNT(CASE WHEN join_time IS NOT NULL THEN 1 END) AS participants_joined,
        COUNT(CASE WHEN leave_time IS NOT NULL THEN 1 END) AS participants_left
        
    FROM {{ source('silver', 'si_participants') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
    GROUP BY meeting_id
),

-- Feature usage metrics per meeting
feature_metrics AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT feature_name) AS features_used_count,
        SUM(usage_count) AS total_feature_usage,
        
        -- Specific feature usage
        SUM(CASE WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN usage_count ELSE 0 END) AS screen_share_usage,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%RECORD%' THEN usage_count ELSE 0 END) AS recording_usage,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%CHAT%' THEN usage_count ELSE 0 END) AS chat_usage,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%FILE%' THEN usage_count ELSE 0 END) AS file_share_usage,
        SUM(CASE WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN usage_count ELSE 0 END) AS breakout_rooms_usage
        
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
    GROUP BY meeting_id
),

-- Meeting activity fact with calculated metrics
meeting_activity_fact AS (
    SELECT 
        m.meeting_id,
        
        -- Date and time dimensions
        m.start_time::DATE AS meeting_date,
        m.start_time AS meeting_start_time,
        m.end_time AS meeting_end_time,
        
        -- Duration metrics
        m.duration_minutes AS scheduled_duration_minutes,
        COALESCE(
            DATEDIFF('minute', m.start_time, m.end_time),
            m.duration_minutes
        ) AS actual_duration_minutes,
        
        -- Participant metrics
        COALESCE(p.participant_count, 0) AS participant_count,
        COALESCE(p.unique_participants, 0) AS unique_participants,
        COALESCE(p.total_join_time_minutes, 0) AS total_join_time_minutes,
        COALESCE(p.average_participation_minutes, 0) AS average_participation_minutes,
        
        -- Engagement score calculation (0-10 scale)
        CASE 
            WHEN p.participant_count > 0 AND m.duration_minutes > 0 THEN
                LEAST(10, 
                    (p.average_participation_minutes / NULLIF(m.duration_minutes, 0)) * 10
                )
            ELSE 0
        END AS participant_engagement_score,
        
        -- Meeting quality score (synthetic - based on duration vs scheduled, participant engagement)
        CASE 
            WHEN m.duration_minutes > 0 THEN
                LEAST(10,
                    (
                        -- Duration adherence (40%)
                        (LEAST(1, COALESCE(DATEDIFF('minute', m.start_time, m.end_time), m.duration_minutes) / NULLIF(m.duration_minutes, 0)) * 4) +
                        -- Participant engagement (40%)
                        (COALESCE(p.average_participation_minutes, 0) / NULLIF(m.duration_minutes, 0) * 4) +
                        -- Feature usage (20%)
                        (LEAST(2, COALESCE(f.features_used_count, 0) / 5.0 * 2))
                    )
                )
            ELSE 0
        END AS meeting_quality_score,
        
        -- Audio/Video quality scores (synthetic - would be from actual telemetry)
        CASE 
            WHEN p.participant_count > 0 THEN
                8.5 + (RANDOM() * 1.5)  -- Simulated between 8.5-10
            ELSE NULL
        END AS audio_quality_score,
        
        CASE 
            WHEN p.participant_count > 0 THEN
                8.0 + (RANDOM() * 2.0)  -- Simulated between 8.0-10
            ELSE NULL
        END AS video_quality_score,
        
        -- Connection stability score (synthetic)
        CASE 
            WHEN p.participant_count > 0 THEN
                9.0 + (RANDOM() * 1.0)  -- Simulated between 9.0-10
            ELSE NULL
        END AS connection_stability_score,
        
        -- Feature usage metrics
        COALESCE(f.features_used_count, 0) AS features_used_count,
        
        -- Estimated durations for specific features (in minutes)
        CASE 
            WHEN f.screen_share_usage > 0 THEN
                LEAST(m.duration_minutes, f.screen_share_usage * 5)  -- Estimate 5 min per usage
            ELSE 0
        END AS screen_share_duration_minutes,
        
        CASE 
            WHEN f.recording_usage > 0 THEN
                m.duration_minutes  -- Assume full meeting recorded if recording used
            ELSE 0
        END AS recording_duration_minutes,
        
        -- Message and interaction counts (estimated)
        CASE 
            WHEN f.chat_usage > 0 THEN
                f.chat_usage * 3  -- Estimate 3 messages per chat usage
            ELSE 0
        END AS chat_messages_count,
        
        COALESCE(f.file_share_usage, 0) AS file_shares_count,
        COALESCE(f.breakout_rooms_usage, 0) AS breakout_rooms_used,
        
        -- Metadata
        m.load_date,
        m.update_date,
        m.source_system
        
    FROM base_meetings m
    LEFT JOIN participant_metrics p ON m.meeting_id = p.meeting_id
    LEFT JOIN feature_metrics f ON m.meeting_id = f.meeting_id
),

-- Final fact table with surrogate key
final_fact AS (
    SELECT 
        -- Generate surrogate key
        ROW_NUMBER() OVER (ORDER BY meeting_date, meeting_start_time) AS meeting_activity_id,
        
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
        load_date,
        update_date,
        source_system
        
    FROM meeting_activity_fact
)

SELECT 
    meeting_activity_id,
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
    load_date,
    update_date,
    source_system
FROM final_fact
ORDER BY meeting_activity_id