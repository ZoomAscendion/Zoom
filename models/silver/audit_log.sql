{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Audit log table structure - must be created first
SELECT
    CAST(NULL AS VARCHAR(255)) AS source_table,
    CAST(NULL AS TIMESTAMP) AS process_start_time,
    CAST(NULL AS TIMESTAMP) AS process_end_time,
    CAST(NULL AS VARCHAR(50)) AS status,
    CAST(NULL AS INTEGER) AS rows_processed,
    CAST(NULL AS VARCHAR(1000)) AS error_message
WHERE FALSE
