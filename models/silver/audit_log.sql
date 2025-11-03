{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

SELECT
    CAST(NULL AS VARCHAR(255)) AS source_table,
    CAST(NULL AS TIMESTAMP_NTZ) AS process_start_time,
    CAST(NULL AS TIMESTAMP_NTZ) AS process_end_time,
    CAST(NULL AS VARCHAR(50)) AS status,
    CAST(NULL AS INTEGER) AS rows_processed,
    CAST(NULL AS VARCHAR(1000)) AS error_message
WHERE FALSE
