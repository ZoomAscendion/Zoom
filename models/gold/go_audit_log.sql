{{ config(
    materialized='table',
    tags=['audit', 'gold']
) }}

WITH base_audit AS (
    SELECT 
        'INITIAL_LOAD' AS process_name,
        'GOLD_LAYER_SETUP' AS process_type,
        CURRENT_TIMESTAMP() AS execution_start_timestamp,
        CURRENT_TIMESTAMP() AS execution_end_timestamp,
        0.0 AS execution_duration_seconds,
        'SUCCESS' AS execution_status,
        'SYSTEM' AS source_table_name,
        'GO_AUDIT_LOG' AS target_table_name,
        1 AS records_read,
        1 AS records_processed,
        1 AS records_inserted,
        0 AS records_updated,
        0 AS records_failed,
        100.0 AS data_quality_score,
        0 AS error_count,
        0 AS warning_count,
        'MANUAL' AS process_trigger,
        'DBT_SYSTEM' AS executed_by,
        'DBT_SERVER' AS server_name,
        '1.0.0' AS process_version,
        PARSE_JSON('{}') AS configuration_parameters,
        PARSE_JSON('{}') AS performance_metrics,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'DBT_GOLD_PIPELINE' AS source_system
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['process_name', 'execution_start_timestamp']) }} AS audit_log_id,
    process_name,
    process_type,
    execution_start_timestamp,
    execution_end_timestamp,
    execution_duration_seconds,
    execution_status,
    LEFT(source_table_name, 200) AS source_table_name,
    LEFT(target_table_name, 200) AS target_table_name,
    records_read,
    records_processed,
    records_inserted,
    records_updated,
    records_failed,
    data_quality_score,
    error_count,
    warning_count,
    LEFT(process_trigger, 100) AS process_trigger,
    LEFT(executed_by, 100) AS executed_by,
    LEFT(server_name, 100) AS server_name,
    LEFT(process_version, 50) AS process_version,
    configuration_parameters,
    performance_metrics,
    load_date,
    update_date,
    LEFT(source_system, 100) AS source_system
FROM base_audit
