{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Audit table for tracking Silver layer pipeline execution
WITH audit_base AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['run_started_at', 'invocation_id']) }} AS execution_id,
        'INITIAL_AUDIT_SETUP' AS pipeline_name,
        '{{ run_started_at }}' AS start_time,
        '{{ run_started_at }}' AS end_time,
        'SUCCESS' AS status,
        NULL AS error_message,
        0 AS execution_duration_seconds,
        'AUDIT_INITIALIZATION' AS source_tables_processed,
        'SI_PIPELINE_AUDIT' AS target_tables_updated,
        0 AS records_processed,
        0 AS records_inserted,
        0 AS records_updated,
        0 AS records_rejected,
        '{{ var("audit_user") }}' AS executed_by,
        'PRODUCTION' AS execution_environment,
        'Initial audit table setup for Silver layer pipeline' AS data_lineage_info,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'DBT_SILVER_PIPELINE' AS source_system
)

SELECT 
    execution_id,
    pipeline_name,
    start_time::TIMESTAMP_NTZ AS start_time,
    end_time::TIMESTAMP_NTZ AS end_time,
    status,
    error_message,
    execution_duration_seconds,
    source_tables_processed,
    target_tables_updated,
    records_processed,
    records_inserted,
    records_updated,
    records_rejected,
    executed_by,
    execution_environment,
    data_lineage_info,
    load_date,
    update_date,
    source_system
FROM audit_base
