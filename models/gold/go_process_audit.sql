{{ config(
    materialized='table',
    pre_hook=None,
    post_hook=None
) }}

-- Process audit table for Gold layer transformations
SELECT 
    audit_key::VARCHAR(255) as audit_key,
    pipeline_name::VARCHAR(255) as pipeline_name,
    execution_start_time::TIMESTAMP_NTZ(9) as execution_start_time,
    execution_end_time::TIMESTAMP_NTZ(9) as execution_end_time,
    execution_duration_seconds::NUMBER(38,0) as execution_duration_seconds,
    source_table_name::VARCHAR(255) as source_table_name,
    target_table_name::VARCHAR(255) as target_table_name,
    records_processed::NUMBER(38,0) as records_processed,
    records_success::NUMBER(38,0) as records_success,
    records_failed::NUMBER(38,0) as records_failed,
    records_rejected::NUMBER(38,0) as records_rejected,
    execution_status::VARCHAR(255) as execution_status,
    error_message::VARCHAR(2000) as error_message,
    processed_by::VARCHAR(255) as processed_by,
    load_timestamp::TIMESTAMP_NTZ(9) as load_timestamp
FROM (
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
) WHERE FALSE -- This ensures the table structure is created but no initial data is inserted
