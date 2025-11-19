{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_READ, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key([\"'GO_FACT_MEETING_ACTIVITY'\", 'CURRENT_TIMESTAMP()']) }}', 'GO_FACT_MEETING_ACTIVITY_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_MEETINGS', 'GO_FACT_MEETING_ACTIVITY', (SELECT COUNT(*) FROM {{ source('silver', 'si_meetings') }}), 'DBT_PIPELINE', 'DBT_SYSTEM', CURRENT_DATE, CURRENT_DATE, 'DBT_GOLD_PIPELINE'",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PROCESS_NAME = 'GO_FACT_MEETING_ACTIVITY_LOAD' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Gold Fact: Meeting Activity Fact Table
-- Central fact table capturing comprehensive meeting activities and engagement metrics

WITH meeting_base AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.MEETING_TOPIC,
        sm.START_TIME,
        sm.END_TIME,
        sm.DURATION_MINUTES,
        sm.DATA_QUALITY_SCORE,
        sm.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE sm.VALIDATION_STATUS = 'PASSED'
),

participant_metrics AS (
    SELECT 
        sp.MEETING_ID,
        COUNT(DISTINCT sp.USER_ID) AS participant_count,
        COUNT(DISTINCT sp.USER_ID) AS unique_participants,
        SUM(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)) AS total_participant_minutes,
        AVG(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)) AS average_participation_minutes,
        COUNT(CASE WHEN sp.JOIN_TIME > DATEADD('minute', 5, (SELECT START_TIME FROM meeting_base mb WHERE mb.MEETING_ID = sp.MEETING_ID)) THEN 1 END) AS late_joiners_count,
        COUNT(CASE WHEN sp.LEAVE_TIME < DATEADD('minute', -5, (SELECT END_TIME FROM meeting_base mb WHERE mb.MEETING_ID = sp.MEETING_ID)) THEN 1 END) AS early_leavers_count
    FROM {{ source('silver', 'si_participants') }} sp
    WHERE sp.VALIDATION_STATUS = 'PASSED'
    GROUP BY sp.MEETING_ID
),

feature_metrics AS (
    SELECT 
        sf.MEETING_ID,
        COUNT(DISTINCT sf.FEATURE_NAME) AS features_used_count,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN sf.USAGE_COUNT ELSE 0 END) AS screen_share_duration_minutes,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%RECORD%' THEN sf.USAGE_COUNT ELSE 0 END) AS recording_duration_minutes,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%CHAT%' THEN sf.USAGE_COUNT ELSE 0 END) AS chat_messages_count,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%FILE%' THEN sf.USAGE_COUNT ELSE 0 END) AS file_shares_count,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%BREAKOUT%' THEN sf.USAGE_COUNT ELSE 0 END) AS breakout_rooms_used,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%POLL%' THEN sf.USAGE_COUNT ELSE 0 END) AS polls_conducted
    FROM {{ source('silver', 'si_feature_usage') }} sf
    WHERE sf.VALIDATION_STATUS = 'PASSED'
    GROUP BY sf.MEETING_ID
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY mb.MEETING_ID) AS MEETING_ACTIVITY_ID,
    dd.DATE_ID,
    mt.MEETING_TYPE_ID,
    du.USER_DIM_ID AS HOST_USER_DIM_ID,
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
LEFT JOIN {{ ref('go_dim_meeting_type') }} mt ON 1=1 -- Simple join for now, can be enhanced
LEFT JOIN participant_metrics pm ON mb.MEETING_ID = pm.MEETING_ID
LEFT JOIN feature_metrics fm ON mb.MEETING_ID = fm.MEETING_ID
