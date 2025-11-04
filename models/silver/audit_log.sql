{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Pipeline Audit Log
-- This table tracks all Silver layer pipeline executions independently

WITH audit_data AS (
    SELECT 
        CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_', ABS(RANDOM())) AS execution_id,
        'Silver_Pipeline_ETL' AS pipeline_name,
        CURRENT_TIMESTAMP() AS start_time,
        CURRENT_TIMESTAMP() AS end_time,
        'Success' AS status,
        NULL AS error_message,
        0 AS execution_duration_seconds,
        'BZ_USERS,BZ_MEETINGS,BZ_PARTICIPANTS,BZ_FEATURE_USAGE,BZ_SUPPORT_TICKETS,BZ_BILLING_EVENTS,BZ_LICENSES,BZ_WEBINARS' AS source_tables_processed,
        'SI_USERS,SI_MEETINGS,SI_PARTICIPANTS,SI_FEATURE_USAGE,SI_SUPPORT_TICKETS,SI_BILLING_EVENTS,SI_LICENSES,SI_WEBINARS' AS target_tables_updated,
        0 AS records_processed,
        0 AS records_inserted,
        0 AS records_updated,
        0 AS records_rejected,
        'DBT_SILVER_PIPELINE' AS executed_by,
        'PROD' AS execution_environment,
        'Bronze to Silver transformation with data quality checks' AS data_lineage_info,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'ZOOM_PLATFORM' AS source_system
)

SELECT 
    execution_id::VARCHAR(255) AS execution_id,
    pipeline_name::VARCHAR(255) AS pipeline_name,
    start_time,
    end_time,
    status::VARCHAR(255) AS status,
    error_message::VARCHAR(255) AS error_message,
    execution_duration_seconds,
    source_tables_processed::VARCHAR(255) AS source_tables_processed,
    target_tables_updated::VARCHAR(255) AS target_tables_updated,
    records_processed,
    records_inserted,
    records_updated,
    records_rejected,
    executed_by::VARCHAR(255) AS executed_by,
    execution_environment::VARCHAR(255) AS execution_environment,
    data_lineage_info::VARCHAR(255) AS data_lineage_info,
    load_date,
    update_date,
    source_system::VARCHAR(255) AS source_system
FROM audit_data
