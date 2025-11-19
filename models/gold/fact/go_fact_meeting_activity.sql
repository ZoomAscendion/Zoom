{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_MEETING_ACTIVITY_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_MEETINGS', 'GO_FACT_MEETING_ACTIVITY', 'DBT_MODEL', 'DBT_SYSTEM', CURRENT_DATE, CURRENT_DATE, 'DBT_GOLD_LAYER')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_MEETING_ACTIVITY_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_MEETINGS', 'GO_FACT_MEETING_ACTIVITY', (SELECT COUNT(*) FROM {{ this }}), 'DBT_MODEL', 'DBT_SYSTEM', CURRENT_DATE, CURRENT_DATE, 'DBT_GOLD_LAYER')"
) }}

-- Meeting Activity Fact Table
WITH source_meetings AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.MEETING_TOPIC,
        sm.START_TIME,
        sm.END_TIME,
        sm.DURATION_MINUTES,
        sm.SOURCE_SYSTEM
    FROM {{ source('silver', 'SI_MEETINGS') }} sm
    WHERE sm.VALIDATION_STATUS = 'PASSED'
),

participant_metrics AS (
    SELECT 
        sp.MEETING_ID,
        COUNT(DISTINCT sp.USER_ID) AS participant_count,
        SUM(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)) AS total_participation_minutes,
        AVG(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)) AS avg_participation_minutes
    FROM {{ source('silver', 'SI_PARTICIPANTS') }} sp
    WHERE sp.VALIDATION_STATUS = 'PASSED'
    GROUP BY sp.MEETING_ID
),

feature_metrics AS (
    SELECT 
        sf.MEETING_ID,
        COUNT(DISTINCT sf.FEATURE_NAME) AS features_used_count,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN sf.USAGE_COUNT ELSE 0 END) AS screen_share_duration_minutes,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%RECORD%' THEN sf.USAGE_COUNT ELSE 0 END) AS recording_duration_minutes,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%CHAT%' THEN sf.USAGE_COUNT ELSE 0 END) AS chat_messages_count
    FROM {{ source('silver', 'SI_FEATURE_USAGE') }} sf
    WHERE sf.VALIDATION_STATUS = 'PASSED'
    GROUP BY sf.MEETING_ID
),

fact_meeting_activity AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sm.MEETING_ID) AS MEETING_ACTIVITY_ID,
        dd.DATE_ID AS DATE_ID,
        dmt.MEETING_TYPE_ID AS MEETING_TYPE_ID,
        du.USER_DIM_ID AS HOST_USER_DIM_ID,
        sm.MEETING_ID,
        DATE(sm.START_TIME) AS MEETING_DATE,
        sm.START_TIME AS MEETING_START_TIME,
        sm.END_TIME AS MEETING_END_TIME,
        sm.DURATION_MINUTES AS SCHEDULED_DURATION_MINUTES,
        sm.DURATION_MINUTES AS ACTUAL_DURATION_MINUTES,
        COALESCE(pm.participant_count, 0) AS PARTICIPANT_COUNT,
        COALESCE(pm.participant_count, 0) AS UNIQUE_PARTICIPANTS,
        sm.DURATION_MINUTES AS HOST_DURATION_MINUTES,
        COALESCE(pm.total_participation_minutes, 0) AS TOTAL_PARTICIPANT_MINUTES,
        COALESCE(pm.avg_participation_minutes, 0) AS AVERAGE_PARTICIPATION_MINUTES,
        COALESCE(pm.participant_count, 0) AS PEAK_CONCURRENT_PARTICIPANTS,
        0 AS LATE_JOINERS_COUNT,
        0 AS EARLY_LEAVERS_COUNT,
        COALESCE(fm.features_used_count, 0) AS FEATURES_USED_COUNT,
        COALESCE(fm.screen_share_duration_minutes, 0) AS SCREEN_SHARE_DURATION_MINUTES,
        COALESCE(fm.recording_duration_minutes, 0) AS RECORDING_DURATION_MINUTES,
        COALESCE(fm.chat_messages_count, 0) AS CHAT_MESSAGES_COUNT,
        0 AS FILE_SHARES_COUNT,
        0 AS BREAKOUT_ROOMS_USED,
        0 AS POLLS_CONDUCTED,
        CASE 
            WHEN COALESCE(pm.participant_count, 0) >= 5 AND COALESCE(pm.avg_participation_minutes, 0) >= (sm.DURATION_MINUTES * 0.8) THEN 5.0
            WHEN COALESCE(pm.participant_count, 0) >= 3 AND COALESCE(pm.avg_participation_minutes, 0) >= (sm.DURATION_MINUTES * 0.6) THEN 4.0
            WHEN COALESCE(pm.participant_count, 0) >= 2 AND COALESCE(pm.avg_participation_minutes, 0) >= (sm.DURATION_MINUTES * 0.4) THEN 3.0
            WHEN COALESCE(pm.participant_count, 0) >= 1 AND COALESCE(pm.avg_participation_minutes, 0) >= (sm.DURATION_MINUTES * 0.2) THEN 2.0
            ELSE 1.0
        END AS MEETING_QUALITY_SCORE,
        5.0 AS AUDIO_QUALITY_SCORE,
        5.0 AS VIDEO_QUALITY_SCORE,
        0 AS CONNECTION_ISSUES_COUNT,
        4.0 AS MEETING_SATISFACTION_SCORE,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        sm.SOURCE_SYSTEM
    FROM source_meetings sm
    LEFT JOIN {{ ref('go_dim_user') }} du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(sm.START_TIME) = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_meeting_type') }} dmt ON dmt.MEETING_TYPE_ID = 1 -- Default meeting type
    LEFT JOIN participant_metrics pm ON sm.MEETING_ID = pm.MEETING_ID
    LEFT JOIN feature_metrics fm ON sm.MEETING_ID = fm.MEETING_ID
)

SELECT * FROM fact_meeting_activity
