{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

SELECT 
    CAST(NULL AS VARCHAR(255)) AS execution_id,
    CAST(NULL AS VARCHAR(255)) AS pipeline_name,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS start_time,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS end_time,
    CAST(NULL AS VARCHAR(255)) AS status,
    CAST(NULL AS VARCHAR(16777216)) AS error_message,
    CAST(NULL AS NUMBER) AS execution_duration_seconds,
    CAST(NULL AS VARCHAR(255)) AS source_tables_processed,
    CAST(NULL AS VARCHAR(255)) AS target_tables_updated,
    CAST(NULL AS NUMBER) AS records_processed,
    CAST(NULL AS NUMBER) AS records_inserted,
    CAST(NULL AS NUMBER) AS records_updated,
    CAST(NULL AS NUMBER) AS records_rejected,
    CAST(NULL AS VARCHAR(255)) AS executed_by,
    CAST(NULL AS VARCHAR(255)) AS execution_environment,
    CAST(NULL AS VARCHAR(16777216)) AS data_lineage_info,
    CAST(NULL AS DATE) AS load_date,
    CAST(NULL AS DATE) AS update_date,
    CAST(NULL AS VARCHAR(255)) AS source_system
WHERE FALSE
