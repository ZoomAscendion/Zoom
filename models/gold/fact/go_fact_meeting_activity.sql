{{ config(
    materialized='table'
) }}

-- Meeting Activity Fact Table
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
),

participant_stats AS (
    SELECT 
        p.MEETING_ID,
        COUNT(*) as participant_count,
        COUNT(DISTINCT p.USER_ID) as unique_participants,
        SUM(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, m.END_TIME))) as total_join_time_minutes,
        AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, m.END_TIME))) as avg_participation_minutes,
        CASE 
            WHEN AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, m.END_TIME))) / NULLIF(m.DURATION_MINUTES, 0) > 0.7 THEN 8.0
            WHEN AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, m.END_TIME))) / NULLIF(m.DURATION_MINUTES, 0) > 0.5 THEN 6.0
            ELSE 4.0
        END as engagement_factor
    FROM {{ source('silver', 'si_participants') }} p
    JOIN meeting_base m ON p.MEETING_ID = m.MEETING_ID
    WHERE p.VALIDATION_STATUS = 'PASSED'
    GROUP BY p.MEETING_ID, m.DURATION_MINUTES
),

feature_stats AS (
    SELECT 
        fu.MEETING_ID,
        COUNT(DISTINCT fu.FEATURE_NAME) as features_used_count,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%screen%' THEN fu.USAGE_COUNT * 5 ELSE 0 END) as screen_share_duration,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%record%' THEN fu.USAGE_COUNT * 10 ELSE 0 END) as recording_duration,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%chat%' THEN fu.USAGE_COUNT ELSE 0 END) as chat_messages_count,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%file%' THEN fu.USAGE_COUNT ELSE 0 END) as file_shares_count,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%breakout%' THEN 1 ELSE 0 END) as breakout_rooms_used,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%video%' THEN 1 ELSE 0 END) as video_features,
        CASE 
            WHEN COUNT(DISTINCT fu.FEATURE_NAME) > 5 THEN 9.0
            WHEN COUNT(DISTINCT fu.FEATURE_NAME) > 2 THEN 7.0
            ELSE 5.0
        END as feature_factor
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
    GROUP BY fu.MEETING_ID
),

meeting_activity_enriched AS (
    SELECT 
        DATE(m.START_TIME) as MEETING_DATE,
        m.START_TIME as MEETING_START_TIME,
        m.END_TIME as MEETING_END_TIME,
        m.DURATION_MINUTES as SCHEDULED_DURATION_MINUTES,
        m.DURATION_MINUTES as ACTUAL_DURATION_MINUTES,
        COALESCE(ps.participant_count, 0) as PARTICIPANT_COUNT,
        COALESCE(ps.unique_participants, 0) as UNIQUE_PARTICIPANTS,
        COALESCE(ps.total_join_time_minutes, 0) as TOTAL_JOIN_TIME_MINUTES,
        COALESCE(ps.avg_participation_minutes, 0) as AVERAGE_PARTICIPATION_MINUTES,
        -- Calculate engagement score based on participation
        CASE 
            WHEN ps.avg_participation_minutes > 0 AND m.DURATION_MINUTES > 0 THEN
                LEAST(10.0, (ps.avg_participation_minutes / m.DURATION_MINUTES) * 10)
            ELSE 0
        END as PARTICIPANT_ENGAGEMENT_SCORE,
        -- Overall meeting quality score
        CASE 
            WHEN ps.participant_count > 0 THEN
                (COALESCE(ps.engagement_factor, 5.0) + COALESCE(fs.feature_factor, 5.0)) / 2.0
            ELSE 5.0
        END as MEETING_QUALITY_SCORE,
        -- Audio quality estimation based on duration and participants
        CASE 
            WHEN m.DURATION_MINUTES > 60 AND ps.participant_count > 10 THEN 7.5
            WHEN m.DURATION_MINUTES > 30 THEN 8.5
            ELSE 9.0
        END as AUDIO_QUALITY_SCORE,
        -- Video quality estimation
        CASE 
            WHEN fs.video_features > 0 THEN 8.0
            ELSE 6.0
        END as VIDEO_QUALITY_SCORE,
        -- Connection stability based on participant behavior
        CASE 
            WHEN ps.avg_participation_minutes / NULLIF(m.DURATION_MINUTES, 0) > 0.8 THEN 9.0
            WHEN ps.avg_participation_minutes / NULLIF(m.DURATION_MINUTES, 0) > 0.6 THEN 7.5
            ELSE 6.0
        END as CONNECTION_STABILITY_SCORE,
        COALESCE(fs.features_used_count, 0) as FEATURES_USED_COUNT,
        COALESCE(fs.screen_share_duration, 0) as SCREEN_SHARE_DURATION_MINUTES,
        COALESCE(fs.recording_duration, 0) as RECORDING_DURATION_MINUTES,
        COALESCE(fs.chat_messages_count, 0) as CHAT_MESSAGES_COUNT,
        COALESCE(fs.file_shares_count, 0) as FILE_SHARES_COUNT,
        COALESCE(fs.breakout_rooms_used, 0) as BREAKOUT_ROOMS_USED,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        m.SOURCE_SYSTEM
    FROM meeting_base m
    LEFT JOIN participant_stats ps ON m.MEETING_ID = ps.MEETING_ID
    LEFT JOIN feature_stats fs ON m.MEETING_ID = fs.MEETING_ID
)

SELECT * FROM meeting_activity_enriched
