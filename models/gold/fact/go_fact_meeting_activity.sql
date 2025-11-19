{{ config(
    materialized='table',
    tags=['fact', 'gold']
) }}

-- Gold Fact: Meeting Activity Fact Table
-- Central fact table capturing comprehensive meeting activities and engagement metrics

WITH meeting_base AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        COALESCE(sm.MEETING_TOPIC, 'Unknown Topic') AS MEETING_TOPIC,
        COALESCE(sm.START_TIME, CURRENT_TIMESTAMP()) AS START_TIME,
        COALESCE(sm.END_TIME, CURRENT_TIMESTAMP()) AS END_TIME,
        COALESCE(sm.DURATION_MINUTES, 0) AS DURATION_MINUTES,
        COALESCE(sm.DATA_QUALITY_SCORE, 0) AS DATA_QUALITY_SCORE,
        COALESCE(sm.SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE COALESCE(sm.VALIDATION_STATUS, 'UNKNOWN') != 'FAILED'
      AND sm.MEETING_ID IS NOT NULL
),

participant_metrics AS (
    SELECT 
        sp.MEETING_ID,
        COUNT(DISTINCT sp.USER_ID) AS participant_count,
        COUNT(DISTINCT sp.USER_ID) AS unique_participants,
        COALESCE(SUM(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)), 0) AS total_participant_minutes,
        COALESCE(AVG(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)), 0) AS average_participation_minutes,
        0 AS late_joiners_count,
        0 AS early_leavers_count
    FROM {{ source('silver', 'si_participants') }} sp
    WHERE COALESCE(sp.VALIDATION_STATUS, 'UNKNOWN') != 'FAILED'
      AND sp.MEETING_ID IS NOT NULL
      AND sp.JOIN_TIME IS NOT NULL
      AND sp.LEAVE_TIME IS NOT NULL
    GROUP BY sp.MEETING_ID
),

feature_metrics AS (
    SELECT 
        sf.MEETING_ID,
        COUNT(DISTINCT sf.FEATURE_NAME) AS features_used_count,
        COALESCE(SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN sf.USAGE_COUNT ELSE 0 END), 0) AS screen_share_duration_minutes,
        COALESCE(SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%RECORD%' THEN sf.USAGE_COUNT ELSE 0 END), 0) AS recording_duration_minutes,
        COALESCE(SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%CHAT%' THEN sf.USAGE_COUNT ELSE 0 END), 0) AS chat_messages_count,
        COALESCE(SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%FILE%' THEN sf.USAGE_COUNT ELSE 0 END), 0) AS file_shares_count,
        COALESCE(SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%BREAKOUT%' THEN sf.USAGE_COUNT ELSE 0 END), 0) AS breakout_rooms_used,
        COALESCE(SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%POLL%' THEN sf.USAGE_COUNT ELSE 0 END), 0) AS polls_conducted
    FROM {{ source('silver', 'si_feature_usage') }} sf
    WHERE COALESCE(sf.VALIDATION_STATUS, 'UNKNOWN') != 'FAILED'
      AND sf.MEETING_ID IS NOT NULL
    GROUP BY sf.MEETING_ID
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY mb.MEETING_ID) AS MEETING_ACTIVITY_ID,
    COALESCE(dd.DATE_ID, 1) AS DATE_ID,
    COALESCE(mt.MEETING_TYPE_ID, 1) AS MEETING_TYPE_ID,
    COALESCE(du.USER_DIM_ID, 1) AS HOST_USER_DIM_ID,
    mb.MEETING_ID,
    DATE(mb.START_TIME) AS MEETING_DATE,
    mb.START_TIME AS MEETING_START_TIME,
    mb.END_TIME AS MEETING_END_TIME,
    mb.DURATION_MINUTES AS SCHEDULED_DURATION_MINUTES,
    mb.DURATION_MINUTES AS ACTUAL_DURATION_MINUTES,
    COALESCE(pm.participant_count, 0) AS PARTICIPANT_COUNT,
    COALESCE(pm.unique_participants, 0) AS UNIQUE_PARTICIPANTS,
    mb.DURATION_MINUTES AS HOST_DURATION_MINUTES,
    COALESCE(pm.total_participant_minutes, 0) AS TOTAL_PARTICIPANT_MINUTES,
    COALESCE(pm.average_participation_minutes, 0) AS AVERAGE_PARTICIPATION_MINUTES,
    COALESCE(pm.participant_count, 0) AS PEAK_CONCURRENT_PARTICIPANTS,
    COALESCE(pm.late_joiners_count, 0) AS LATE_JOINERS_COUNT,
    COALESCE(pm.early_leavers_count, 0) AS EARLY_LEAVERS_COUNT,
    COALESCE(fm.features_used_count, 0) AS FEATURES_USED_COUNT,
    COALESCE(fm.screen_share_duration_minutes, 0) AS SCREEN_SHARE_DURATION_MINUTES,
    COALESCE(fm.recording_duration_minutes, 0) AS RECORDING_DURATION_MINUTES,
    COALESCE(fm.chat_messages_count, 0) AS CHAT_MESSAGES_COUNT,
    COALESCE(fm.file_shares_count, 0) AS FILE_SHARES_COUNT,
    COALESCE(fm.breakout_rooms_used, 0) AS BREAKOUT_ROOMS_USED,
    COALESCE(fm.polls_conducted, 0) AS POLLS_CONDUCTED,
    CASE 
        WHEN COALESCE(pm.participant_count, 0) >= 5 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.DURATION_MINUTES * 0.8) THEN 5.0
        WHEN COALESCE(pm.participant_count, 0) >= 3 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.DURATION_MINUTES * 0.6) THEN 4.0
        WHEN COALESCE(pm.participant_count, 0) >= 2 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.DURATION_MINUTES * 0.4) THEN 3.0
        WHEN COALESCE(pm.participant_count, 0) >= 1 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.DURATION_MINUTES * 0.2) THEN 2.0
        ELSE 1.0
    END AS MEETING_QUALITY_SCORE,
    CASE 
        WHEN mb.DATA_QUALITY_SCORE >= 90 THEN 5.0
        WHEN mb.DATA_QUALITY_SCORE >= 80 THEN 4.0
        WHEN mb.DATA_QUALITY_SCORE >= 70 THEN 3.0
        ELSE 2.0
    END AS AUDIO_QUALITY_SCORE,
    CASE 
        WHEN mb.DATA_QUALITY_SCORE >= 90 THEN 5.0
        WHEN mb.DATA_QUALITY_SCORE >= 80 THEN 4.0
        WHEN mb.DATA_QUALITY_SCORE >= 70 THEN 3.0
        ELSE 2.0
    END AS VIDEO_QUALITY_SCORE,
    0 AS CONNECTION_ISSUES_COUNT,
    CASE 
        WHEN COALESCE(pm.participant_count, 0) >= 5 AND mb.DURATION_MINUTES >= 30 THEN 5.0
        WHEN COALESCE(pm.participant_count, 0) >= 3 AND mb.DURATION_MINUTES >= 15 THEN 4.0
        WHEN COALESCE(pm.participant_count, 0) >= 2 THEN 3.0
        WHEN COALESCE(pm.participant_count, 0) >= 1 THEN 2.0
        ELSE 1.0
    END AS MEETING_SATISFACTION_SCORE,
    CURRENT_DATE AS LOAD_DATE,
    CURRENT_DATE AS UPDATE_DATE,
    mb.SOURCE_SYSTEM
FROM meeting_base mb
LEFT JOIN {{ ref('go_dim_user') }} du ON mb.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(mb.START_TIME) = dd.DATE_VALUE
LEFT JOIN {{ ref('go_dim_meeting_type') }} mt ON 1=1 -- Simple join for now
LEFT JOIN participant_metrics pm ON mb.MEETING_ID = pm.MEETING_ID
LEFT JOIN feature_metrics fm ON mb.MEETING_ID = fm.MEETING_ID
