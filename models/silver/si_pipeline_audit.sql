{{ config(
    materialized='table'
) }}

-- Silver Pipeline Audit Table - Independent audit for Silver layer
-- This model creates the audit table structure for Silver layer processing

WITH audit_base AS (
    SELECT 
        CONCAT('INIT_', REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_')) AS execution_id,
        'SI_PIPELINE_AUDIT_INIT' AS pipeline_name,
        CURRENT_TIMESTAMP() AS start_time,
        CURRENT_TIMESTAMP() AS end_time,
        'SUCCESS' AS status,
        NULL AS error_message,
        0 AS execution_duration_seconds,
        'BRONZE_TABLES' AS source_tables_processed,
        'SI_PIPELINE_AUDIT' AS target_tables_updated,
        1 AS records_processed,
        1 AS records_inserted,
        0 AS records_updated,
        0 AS records_rejected,
        'DBT_SILVER_PIPELINE' AS executed_by,
        'PRODUCTION' AS execution_environment,
        'Silver layer audit table initialization' AS data_lineage_info,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'ZOOM_PLATFORM' AS source_system
)

SELECT 
    execution_id,
    pipeline_name,
    start_time,
    end_time,
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
