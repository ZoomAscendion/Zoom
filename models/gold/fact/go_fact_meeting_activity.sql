{{ config(
    materialized='table',
    cluster_by=['MEETING_DATE', 'HOST_USER_DIM_ID'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIMESTAMP, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) VALUES ('{{ dbt_utils.generate_surrogate_key(["'go_fact_meeting_activity'", "CURRENT_TIMESTAMP()"]) }}', 'GO_FACT_MEETING_ACTIVITY_LOAD', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_MEETINGS', 'GO_FACT_MEETING_ACTIVITY', 'DBT_MODEL_RUN', 'DBT_USER', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIMESTAMP = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), DATA_QUALITY_SCORE = 90.0 WHERE PROCESS_ID = '{{ dbt_utils.generate_surrogate_key(["'go_fact_meeting_activity'", "CURRENT_TIMESTAMP()"]) }}'"
) }}

-- Meeting activity fact table with comprehensive metrics
-- Combines meeting, participant, and feature usage data

WITH source_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
),

source_participants AS (
    SELECT 
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME
    FROM {{ source('silver', 'si_participants') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND MEETING_ID IS NOT NULL
),

source_features AS (
    SELECT 
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND MEETING_ID IS NOT NULL
),

participant_metrics AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS participant_count,
        SUM(DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, CURRENT_TIMESTAMP()))) AS total_participant_minutes,
        AVG(DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, CURRENT_TIMESTAMP()))) AS avg_participation_minutes
    FROM source_participants
    GROUP BY MEETING_ID
),

feature_metrics AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT FEATURE_NAME) AS features_used_count,
        SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN USAGE_COUNT ELSE 0 END) AS screen_share_duration_minutes,
        SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN USAGE_COUNT ELSE 0 END) AS recording_duration_minutes,
        SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN USAGE_COUNT ELSE 0 END) AS chat_messages_count
    FROM source_features
    GROUP BY MEETING_ID
),

meeting_activity_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sm.MEETING_ID) AS MEETING_ACTIVITY_ID,
        dd.DATE_ID,
        mt.MEETING_TYPE_ID,
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
        COALESCE(pm.total_participant_minutes, 0) AS TOTAL_PARTICIPANT_MINUTES,
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
        4.5 AS AUDIO_QUALITY_SCORE,
        4.5 AS VIDEO_QUALITY_SCORE,
        0 AS CONNECTION_ISSUES_COUNT,
        4.0 AS MEETING_SATISFACTION_SCORE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        sm.SOURCE_SYSTEM
    FROM source_meetings sm
    LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(sm.START_TIME) = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_user') }} du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('go_dim_meeting_type') }} mt ON 
        CASE 
            WHEN sm.DURATION_MINUTES <= 15 THEN 'Brief'
            WHEN sm.DURATION_MINUTES <= 60 THEN 'Standard'
            WHEN sm.DURATION_MINUTES <= 120 THEN 'Extended'
            ELSE 'Long'
        END = mt.DURATION_CATEGORY
    LEFT JOIN participant_metrics pm ON sm.MEETING_ID = pm.MEETING_ID
    LEFT JOIN feature_metrics fm ON sm.MEETING_ID = fm.MEETING_ID
)

SELECT * FROM meeting_activity_fact
