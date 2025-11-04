{{ config(
    materialized='table'
) }}

-- Silver Layer Pipeline Audit Table
-- Description: Independent audit table for tracking Silver layer pipeline execution

SELECT 
    REPLACE(UUID_STRING(), '-', '') AS execution_id,
    'INITIAL_SETUP' AS pipeline_name,
    CURRENT_TIMESTAMP() AS start_time,
    CURRENT_TIMESTAMP() AS end_time,
    'COMPLETED' AS status,
    NULL AS error_message,
    0 AS execution_duration_seconds,
    'AUDIT_TABLE_SETUP' AS source_tables_processed,
    'SI_PIPELINE_AUDIT' AS target_tables_updated,
    1 AS records_processed,
    1 AS records_inserted,
    0 AS records_updated,
    0 AS records_rejected,
    CURRENT_USER() AS executed_by,
    'PROD' AS execution_environment,
    'Initial audit table setup for Silver layer pipeline' AS data_lineage_info,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_SILVER_PIPELINE' AS source_system
WHERE FALSE  -- This ensures no actual records are inserted during initial setup

UNION ALL

-- Create the structure for future audit records
SELECT 
    'TEMPLATE' AS execution_id,
    'TEMPLATE' AS pipeline_name,
    CURRENT_TIMESTAMP() AS start_time,
    CURRENT_TIMESTAMP() AS end_time,
    'TEMPLATE' AS status,
    NULL AS error_message,
    0 AS execution_duration_seconds,
    'TEMPLATE' AS source_tables_processed,
    'TEMPLATE' AS target_tables_updated,
    0 AS records_processed,
    0 AS records_inserted,
    0 AS records_updated,
    0 AS records_rejected,
    'SYSTEM' AS executed_by,
    'TEMPLATE' AS execution_environment,
    'Template record for audit table structure' AS data_lineage_info,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_SILVER_PIPELINE' AS source_system
WHERE FALSE  -- This ensures no template records are actually inserted
