{{ config(
    materialized='table',
    unique_key='record_id'
) }}

SELECT 
    1 AS record_id,
    'SYSTEM' AS source_table,
    CURRENT_TIMESTAMP() AS process_start_time,
    CURRENT_TIMESTAMP() AS process_end_time,
    'INITIALIZED' AS process_status,
    NULL AS error_message,
    0 AS records_processed,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
WHERE 1=0
