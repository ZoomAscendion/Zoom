{{ config(
    materialized='table'
) }}

SELECT 
    1 AS record_id,
    'SYSTEM_INIT' AS source_table,
    CURRENT_TIMESTAMP() AS process_start_time,
    CURRENT_TIMESTAMP() AS process_end_time,
    'INITIALIZED' AS process_status,
    CAST(NULL AS VARCHAR(1000)) AS error_message,
    0 AS records_processed,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
