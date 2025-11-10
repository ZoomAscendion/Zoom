{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_FACT_MEETING_ACTIVITY_TRANSFORMATION', 'SI_MEETINGS', 'GO_FACT_MEETING_ACTIVITY', CURRENT_TIMESTAMP(), 'STARTED', 'Meeting activity fact transformation started', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_FACT_MEETING_ACTIVITY_TRANSFORMATION', 'SI_MEETINGS', 'GO_FACT_MEETING_ACTIVITY', CURRENT_TIMESTAMP(), 'COMPLETED', 'Meeting activity fact transformation completed successfully', CURRENT_DATE(), CURRENT_DATE())"
) }}

-- Meeting Activity Fact Table
-- Comprehensive meeting analytics with participant and feature metrics

WITH meeting_base AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        m.MEETING_TOPIC,
        m.START_TIME,
        m.END_TIME,
        m.DURATION_MINUTES,
        m.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }} m
    WHERE m.VALIDATION_STATUS = 'PASSED'
        AND m.DATA_QUALITY_SCORE >= 80
        AND m.DURATION_MINUTES > 0
),

participant_stats AS (
    SELECT 
        p.MEETING_ID,
        COUNT(*) AS participant_count,
        COUNT(DISTINCT p.USER_ID) AS unique_participants,
        SUM(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, mb.END_TIME))) AS total_join_time_minutes,
        AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, mb.END_TIME))) AS avg_participation_minutes,
        CASE 
            WHEN AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, mb.END_TIME))) / NULLIF(mb.DURATION_MINUTES, 0) > 0.7 THEN 8.0
            WHEN AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, mb.END_TIME))) / NULLIF(mb.DURATION_MINUTES, 0) > 0.5 THEN 6.0
            ELSE 4.0
        END AS engagement_factor
    FROM {{ source('silver', 'si_participants') }} p
    JOIN meeting_base mb ON p.MEETING_ID = mb.MEETING_ID
    WHERE p.VALIDATION_STATUS = 'PASSED'
    GROUP BY p.MEETING_ID
),

feature_stats AS (
    SELECT 
        fu.MEETING_ID,
        COUNT(DISTINCT fu.FEATURE_NAME) AS features_used_count,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%SCREEN%' THEN fu.USAGE_COUNT * 5 ELSE 0 END) AS screen_share_duration,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%RECORD%' THEN fu.USAGE_COUNT * 10 ELSE 0 END) AS recording_duration,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%CHAT%' THEN fu.USAGE_COUNT ELSE 0 END) AS chat_messages_count,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%FILE%' THEN fu.USAGE_COUNT ELSE 0 END) AS file_shares_count,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%BREAKOUT%' THEN 1 ELSE 0 END) AS breakout_rooms_used,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%VIDEO%' THEN 1 ELSE 0 END) AS video_features,
        CASE 
            WHEN COUNT(DISTINCT fu.FEATURE_NAME) > 5 THEN 9.0
            WHEN COUNT(DISTINCT fu.FEATURE_NAME) > 2 THEN 7.0
            ELSE 5.0
        END AS feature_factor
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
    GROUP BY fu.MEETING_ID
),

meeting_activity_metrics AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY mb.MEETING_ID) AS MEETING_ACTIVITY_ID,
        DATE(mb.START_TIME) AS MEETING_DATE,
        mb.START_TIME AS MEETING_START_TIME,
        mb.END_TIME AS MEETING_END_TIME,
        mb.DURATION_MINUTES AS SCHEDULED_DURATION_MINUTES,
        mb.DURATION_MINUTES AS ACTUAL_DURATION_MINUTES,
        COALESCE(ps.participant_count, 0) AS PARTICIPANT_COUNT,
        COALESCE(ps.unique_participants, 0) AS UNIQUE_PARTICIPANTS,
        COALESCE(ps.total_join_time_minutes, 0) AS TOTAL_JOIN_TIME_MINUTES,
        COALESCE(ps.avg_participation_minutes, 0) AS AVERAGE_PARTICIPATION_MINUTES,
        -- Engagement score calculation
        CASE 
            WHEN ps.avg_participation_minutes > 0 AND mb.DURATION_MINUTES > 0 THEN
                LEAST(10.0, (ps.avg_participation_minutes / mb.DURATION_MINUTES) * 10)
            ELSE 0
        END AS PARTICIPANT_ENGAGEMENT_SCORE,
        -- Overall meeting quality score
        CASE 
            WHEN ps.participant_count > 0 THEN
                (COALESCE(ps.engagement_factor, 5.0) + COALESCE(fs.feature_factor, 5.0)) / 2.0
            ELSE 5.0
        END AS MEETING_QUALITY_SCORE,
        -- Audio quality estimation
        CASE 
            WHEN mb.DURATION_MINUTES > 60 AND ps.participant_count > 10 THEN 7.5
            WHEN mb.DURATION_MINUTES > 30 THEN 8.5
            ELSE 9.0
        END AS AUDIO_QUALITY_SCORE,
        -- Video quality estimation
        CASE 
            WHEN fs.video_features > 0 THEN 8.0
            ELSE 6.0
        END AS VIDEO_QUALITY_SCORE,
        -- Connection stability score
        CASE 
            WHEN ps.avg_participation_minutes / NULLIF(mb.DURATION_MINUTES, 0) > 0.8 THEN 9.0
            WHEN ps.avg_participation_minutes / NULLIF(mb.DURATION_MINUTES, 0) > 0.6 THEN 7.5
            ELSE 6.0
        END AS CONNECTION_STABILITY_SCORE,
        COALESCE(fs.features_used_count, 0) AS FEATURES_USED_COUNT,
        COALESCE(fs.screen_share_duration, 0) AS SCREEN_SHARE_DURATION_MINUTES,
        COALESCE(fs.recording_duration, 0) AS RECORDING_DURATION_MINUTES,
        COALESCE(fs.chat_messages_count, 0) AS CHAT_MESSAGES_COUNT,
        COALESCE(fs.file_shares_count, 0) AS FILE_SHARES_COUNT,
        COALESCE(fs.breakout_rooms_used, 0) AS BREAKOUT_ROOMS_USED,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        mb.SOURCE_SYSTEM
    FROM meeting_base mb
    LEFT JOIN participant_stats ps ON mb.MEETING_ID = ps.MEETING_ID
    LEFT JOIN feature_stats fs ON mb.MEETING_ID = fs.MEETING_ID
)

SELECT * FROM meeting_activity_metrics
ORDER BY MEETING_ACTIVITY_ID
