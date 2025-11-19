{{ config(
    materialized='table'
) }}

-- Gold layer audit log table
-- This table must be created first and run before any other models

SELECT
    {{ dbt_utils.generate_surrogate_key(['process_name', 'execution_start_timestamp']) }} AS audit_log_id,
    'INITIAL_LOAD' AS process_name,
    'DBT_MODEL' AS process_type,
    CURRENT_TIMESTAMP() AS execution_start_timestamp,
    NULL AS execution_end_timestamp,
    NULL AS execution_duration_seconds,
    'RUNNING' AS execution_status,
    'SYSTEM' AS source_table_name,
    'GO_AUDIT_LOG' AS target_table_name,
    0 AS records_read,
    0 AS records_processed,
    1 AS records_inserted,
    0 AS records_updated,
    0 AS records_failed,
    100.0 AS data_quality_score,
    0 AS error_count,
    0 AS warning_count,
    'DBT_INITIAL_LOAD' AS process_trigger,
    'DBT_SYSTEM' AS executed_by,
    'SNOWFLAKE' AS server_name,
    '1.0.0' AS process_version,
    PARSE_JSON('{}') AS configuration_parameters,
    PARSE_JSON('{}') AS performance_metrics,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_GOLD_PIPELINE' AS source_system

WHERE 1=1
