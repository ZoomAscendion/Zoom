{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Audit Log Table
-- This table must be created first to track all pipeline executions

SELECT 
    {{ dbt_utils.generate_surrogate_key(['execution_id']) }} as audit_id,
    'INITIAL_SETUP' as execution_id,
    'SI_AUDIT_LOG' as pipeline_name,
    CURRENT_TIMESTAMP() as start_time,
    CURRENT_TIMESTAMP() as end_time,
    'SUCCESS' as status,
    NULL as error_message,
    0 as execution_duration_seconds,
    'SYSTEM_INITIALIZATION' as source_tables_processed,
    'SI_AUDIT_LOG' as target_tables_updated,
    0 as records_processed,
    0 as records_inserted,
    0 as records_updated,
    0 as records_rejected,
    '{{ var("audit_user") }}' as executed_by,
    'PROD' as execution_environment,
    'Initial audit log setup' as data_lineage_info,
    CURRENT_DATE() as load_date,
    CURRENT_DATE() as update_date,
    'DBT_SILVER_PIPELINE' as source_system

WHERE FALSE -- This ensures no actual records are inserted during initial setup

UNION ALL

-- Create the actual audit log structure
SELECT 
    {{ dbt_utils.generate_surrogate_key(['pipeline_name', 'start_time']) }} as audit_id,
    {{ dbt_utils.generate_surrogate_key(['pipeline_name', 'start_time']) }} as execution_id,
    'SI_AUDIT_LOG_INITIALIZATION' as pipeline_name,
    '{{ var("current_timestamp") }}' as start_time,
    '{{ var("current_timestamp") }}' as end_time,
    'SUCCESS' as status,
    NULL as error_message,
    0 as execution_duration_seconds,
    'SYSTEM' as source_tables_processed,
    'SI_AUDIT_LOG' as target_tables_updated,
    1 as records_processed,
    1 as records_inserted,
    0 as records_updated,
    0 as records_rejected,
    '{{ var("audit_user") }}' as executed_by,
    'PROD' as execution_environment,
    'Audit log table initialization for Silver layer pipeline tracking' as data_lineage_info,
    CURRENT_DATE() as load_date,
    CURRENT_DATE() as update_date,
    'DBT_SILVER_PIPELINE' as source_system
