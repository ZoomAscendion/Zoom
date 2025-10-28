{{ config(
    materialized='table'
) }}

-- Process audit table for Gold layer transformations
SELECT 
    'INITIAL_AUDIT' as audit_key,
    'Gold Layer Initialization' as pipeline_name,
    CURRENT_TIMESTAMP() as execution_start_time,
    CURRENT_TIMESTAMP() as execution_end_time,
    0 as execution_duration_seconds,
    'SYSTEM' as source_table_name,
    'go_process_audit' as target_table_name,
    1 as records_processed,
    1 as records_success,
    0 as records_failed,
    0 as records_rejected,
    'COMPLETED' as execution_status,
    NULL as error_message,
    'DBT_SYSTEM' as processed_by,
    CURRENT_TIMESTAMP() as load_timestamp
WHERE FALSE -- This ensures the table structure is created but no initial data is inserted
