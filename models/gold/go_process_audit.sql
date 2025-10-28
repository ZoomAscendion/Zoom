{{ config(
    materialized='table',
    pre_hook=None,
    post_hook=None
) }}

-- Process audit table for Gold layer transformations
SELECT 
    'INITIAL_AUDIT'::VARCHAR(255) as audit_key,
    'Gold Layer Initialization'::VARCHAR(255) as pipeline_name,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ(9) as execution_start_time,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ(9) as execution_end_time,
    0::NUMBER(38,0) as execution_duration_seconds,
    'SYSTEM'::VARCHAR(255) as source_table_name,
    'go_process_audit'::VARCHAR(255) as target_table_name,
    1::NUMBER(38,0) as records_processed,
    1::NUMBER(38,0) as records_success,
    0::NUMBER(38,0) as records_failed,
    0::NUMBER(38,0) as records_rejected,
    'COMPLETED'::VARCHAR(255) as execution_status,
    NULL::VARCHAR(2000) as error_message,
    'DBT_SYSTEM'::VARCHAR(255) as processed_by,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ(9) as load_timestamp
WHERE FALSE -- This ensures the table structure is created but no initial data is inserted
