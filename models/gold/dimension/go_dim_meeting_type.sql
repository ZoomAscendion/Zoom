{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_DIM_MEETING_TYPE\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_DIM_MEETING_TYPE' AS process_name, 'DIMENSION_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_MEETINGS' AS source_table_name, 'GO_DIM_MEETING_TYPE' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_DIM_MEETING_TYPE' AND execution_status = 'RUNNING'"
) }}

WITH source_meetings AS (
    SELECT DISTINCT
        DURATION_MINUTES,
        START_TIME,
        DATA_QUALITY_SCORE,
        SOURCE_SYSTEM
    FROM {{ ref('SI_Meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY DURATION_MINUTES) AS meeting_type_id,
    'Standard Meeting' AS meeting_type,
    CASE 
        WHEN DURATION_MINUTES <= 15 THEN 'Quick Sync'
        WHEN DURATION_MINUTES <= 60 THEN 'Standard Meeting'
        WHEN DURATION_MINUTES <= 120 THEN 'Extended Meeting'
        ELSE 'Long Session'
    END AS meeting_category,
    CASE 
        WHEN DURATION_MINUTES <= 15 THEN 'Brief'
        WHEN DURATION_MINUTES <= 60 THEN 'Standard'
        WHEN DURATION_MINUTES <= 120 THEN 'Extended'
        ELSE 'Long'
    END AS duration_category,
    'Unknown' AS participant_size_category,
    CASE 
        WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day_category,
    DAYNAME(START_TIME) AS day_of_week,
    CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend_meeting,
    FALSE AS is_recurring_type,
    CASE 
        WHEN DATA_QUALITY_SCORE >= 90 THEN 9.0
        WHEN DATA_QUALITY_SCORE >= 80 THEN 8.0
        WHEN DATA_QUALITY_SCORE >= 70 THEN 7.0
        ELSE 6.0
    END AS meeting_quality_threshold,
    'Standard meeting features' AS typical_features_used,
    'Business Meeting' AS business_purpose,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM source_meetings
