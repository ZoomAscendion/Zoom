{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Pipeline Audit Log Model
-- This model must run first to create the audit table before other models

WITH audit_base AS (
    SELECT 
        -- Generate unique execution ID
        'EXEC_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS') || '_' || ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS execution_id,
        
        -- Pipeline execution details
        'SILVER_LAYER_INITIALIZATION' AS pipeline_name,
        CURRENT_TIMESTAMP() AS start_time,
        CURRENT_TIMESTAMP() AS end_time,
        'SUCCESS' AS status,
        NULL AS error_message,
        0 AS execution_duration_seconds,
        'BRONZE_TABLES' AS source_tables_processed,
        'SILVER_TABLES' AS target_tables_updated,
        0 AS records_processed,
        0 AS records_inserted,
        0 AS records_updated,
        0 AS records_rejected,
        'DBT_SILVER_PIPELINE' AS executed_by,
        'PRODUCTION' AS execution_environment,
        'Bronze to Silver transformation pipeline' AS data_lineage_info,
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'DBT_PIPELINE' AS source_system
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
