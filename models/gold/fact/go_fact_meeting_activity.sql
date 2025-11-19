{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_FACT_MEETING_ACTIVITY\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_FACT_MEETING_ACTIVITY' AS process_name, 'FACT_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_MEETINGS' AS source_table_name, 'GO_FACT_MEETING_ACTIVITY' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_FACT_MEETING_ACTIVITY' AND execution_status = 'RUNNING'"
) }}

WITH meeting_base AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.MEETING_TOPIC,
        sm.START_TIME,
        sm.END_TIME,
        sm.DURATION_MINUTES,
        sm.DATA_QUALITY_SCORE,
        sm.SOURCE_SYSTEM,
        DATE(sm.START_TIME) AS meeting_date
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE sm.VALIDATION_STATUS = 'PASSED'
),

participant_metrics AS (
    SELECT 
        sp.MEETING_ID,
        COUNT(DISTINCT sp.USER_ID) AS participant_count,
        SUM(DATEDIFF('minute', sp.JOIN_TIME, COALESCE(sp.LEAVE_TIME, CURRENT_TIMESTAMP()))) AS total_participant_minutes,
        AVG(DATEDIFF('minute', sp.JOIN_TIME, COALESCE(sp.LEAVE_TIME, CURRENT_TIMESTAMP()))) AS average_participation_minutes
    FROM {{ source('silver', 'si_participants') }} sp
    WHERE sp.VALIDATION_STATUS = 'PASSED'
    GROUP BY sp.MEETING_ID
),

feature_metrics AS (
    SELECT 
        sf.MEETING_ID,
        COUNT(DISTINCT sf.FEATURE_NAME) AS features_used_count,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN sf.USAGE_COUNT ELSE 0 END) AS screen_share_usage_count,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%RECORD%' THEN sf.USAGE_COUNT ELSE 0 END) AS recording_usage_count,
        SUM(CASE WHEN UPPER(sf.FEATURE_NAME) LIKE '%CHAT%' THEN sf.USAGE_COUNT ELSE 0 END) AS chat_messages_count
    FROM {{ source('silver', 'si_feature_usage') }} sf
    WHERE sf.VALIDATION_STATUS = 'PASSED'
    GROUP BY sf.MEETING_ID
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY mb.MEETING_ID) AS meeting_activity_id,
    dd.date_id AS date_id,
    dmt.meeting_type_id AS meeting_type_id,
    du.user_dim_id AS host_user_dim_id,
    mb.MEETING_ID AS meeting_id,
    mb.meeting_date,
    mb.START_TIME AS meeting_start_time,
    mb.END_TIME AS meeting_end_time,
    mb.DURATION_MINUTES AS scheduled_duration_minutes,
    mb.DURATION_MINUTES AS actual_duration_minutes,
    COALESCE(pm.participant_count, 0) AS participant_count,
    COALESCE(pm.participant_count, 0) AS unique_participants,
    mb.DURATION_MINUTES AS host_duration_minutes,
    COALESCE(pm.total_participant_minutes, 0) AS total_participant_minutes,
    COALESCE(pm.average_participation_minutes, 0) AS average_participation_minutes,
    COALESCE(pm.participant_count, 0) AS peak_concurrent_participants,
    0 AS late_joiners_count,
    0 AS early_leavers_count,
    COALESCE(fm.features_used_count, 0) AS features_used_count,
    0 AS screen_share_duration_minutes,
    0 AS recording_duration_minutes,
    COALESCE(fm.chat_messages_count, 0) AS chat_messages_count,
    0 AS file_shares_count,
    0 AS breakout_rooms_used,
    0 AS polls_conducted,
    CASE 
        WHEN COALESCE(pm.participant_count, 0) >= 5 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.DURATION_MINUTES * 0.8) THEN 5.0
        WHEN COALESCE(pm.participant_count, 0) >= 3 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.DURATION_MINUTES * 0.6) THEN 4.0
        WHEN COALESCE(pm.participant_count, 0) >= 2 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.DURATION_MINUTES * 0.4) THEN 3.0
        WHEN COALESCE(pm.participant_count, 0) >= 1 AND COALESCE(pm.average_participation_minutes, 0) >= (mb.DURATION_MINUTES * 0.2) THEN 2.0
        ELSE 1.0
    END AS meeting_quality_score,
    CASE 
        WHEN mb.DATA_QUALITY_SCORE >= 90 THEN 5.0
        WHEN mb.DATA_QUALITY_SCORE >= 80 THEN 4.0
        WHEN mb.DATA_QUALITY_SCORE >= 70 THEN 3.0
        WHEN mb.DATA_QUALITY_SCORE >= 60 THEN 2.0
        ELSE 1.0
    END AS audio_quality_score,
    CASE 
        WHEN mb.DATA_QUALITY_SCORE >= 90 THEN 5.0
        WHEN mb.DATA_QUALITY_SCORE >= 80 THEN 4.0
        WHEN mb.DATA_QUALITY_SCORE >= 70 THEN 3.0
        WHEN mb.DATA_QUALITY_SCORE >= 60 THEN 2.0
        ELSE 1.0
    END AS video_quality_score,
    0 AS connection_issues_count,
    CASE 
        WHEN COALESCE(pm.participant_count, 0) >= 5 AND mb.DURATION_MINUTES >= 30 THEN 5.0
        WHEN COALESCE(pm.participant_count, 0) >= 3 AND mb.DURATION_MINUTES >= 15 THEN 4.0
        WHEN COALESCE(pm.participant_count, 0) >= 2 THEN 3.0
        WHEN COALESCE(pm.participant_count, 0) >= 1 THEN 2.0
        ELSE 1.0
    END AS meeting_satisfaction_score,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(mb.SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM meeting_base mb
LEFT JOIN {{ ref('go_dim_date') }} dd ON mb.meeting_date = dd.date_key
LEFT JOIN {{ ref('go_dim_meeting_type') }} dmt ON 1=1  -- Simple join for now
LEFT JOIN {{ ref('go_dim_user') }} du ON mb.HOST_ID = du.user_id AND du.is_current_record = TRUE
LEFT JOIN participant_metrics pm ON mb.MEETING_ID = pm.MEETING_ID
LEFT JOIN feature_metrics fm ON mb.MEETING_ID = fm.MEETING_ID
