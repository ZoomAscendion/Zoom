{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_FACT_FEATURE_USAGE\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_FACT_FEATURE_USAGE' AS process_name, 'FACT_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_FEATURE_USAGE' AS source_table_name, 'GO_FACT_FEATURE_USAGE' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_FACT_FEATURE_USAGE' AND execution_status = 'RUNNING'"
) }}

WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM
    FROM {{ ref('SI_Feature_Usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
),

meeting_context AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.DURATION_MINUTES
    FROM {{ ref('SI_Meetings') }} sm
    WHERE sm.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY fub.USAGE_ID) AS feature_usage_id,
    dd.date_id AS date_id,
    df.feature_id AS feature_id,
    du.user_dim_id AS user_dim_id,
    fub.MEETING_ID AS meeting_id,
    fub.USAGE_DATE,
    fub.USAGE_DATE::TIMESTAMP_NTZ AS usage_timestamp,
    fub.FEATURE_NAME,
    fub.USAGE_COUNT,
    COALESCE(mc.DURATION_MINUTES, 0) AS usage_duration_minutes,
    COALESCE(mc.DURATION_MINUTES, 0) AS session_duration_minutes,
    CASE 
        WHEN fub.USAGE_COUNT >= 10 THEN 5.0
        WHEN fub.USAGE_COUNT >= 5 THEN 4.0
        WHEN fub.USAGE_COUNT >= 3 THEN 3.0
        WHEN fub.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END AS feature_adoption_score,
    CASE 
        WHEN fub.USAGE_COUNT >= 5 THEN 5.0
        WHEN fub.USAGE_COUNT >= 3 THEN 4.0
        WHEN fub.USAGE_COUNT >= 2 THEN 3.0
        WHEN fub.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END AS user_experience_rating,
    CASE 
        WHEN fub.USAGE_COUNT > 0 THEN 5.0
        ELSE 1.0
    END AS feature_performance_score,
    1 AS concurrent_features_count,
    CASE 
        WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 60 THEN 'Extended Session'
        WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 30 THEN 'Standard Session'
        WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 15 THEN 'Short Session'
        WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 5 THEN 'Brief Session'
        ELSE 'Quick Access'
    END AS usage_context,
    'Desktop' AS device_type,
    '1.0.0' AS platform_version,
    0 AS error_count,
    CASE 
        WHEN fub.USAGE_COUNT > 0 THEN 100.0
        ELSE 0.0
    END AS success_rate,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(fub.SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM feature_usage_base fub
LEFT JOIN {{ ref('go_dim_date') }} dd ON fub.USAGE_DATE = dd.date_key
LEFT JOIN {{ ref('go_dim_feature') }} df ON fub.FEATURE_NAME = df.feature_name
LEFT JOIN meeting_context mc ON fub.MEETING_ID = mc.MEETING_ID
LEFT JOIN {{ ref('go_dim_user') }} du ON mc.HOST_ID = du.user_id AND du.is_current_record = TRUE
