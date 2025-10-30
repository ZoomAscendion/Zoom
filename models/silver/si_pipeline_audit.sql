{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Create the audit log table structure first
SELECT 
    CAST('INIT_001' AS VARCHAR(255)) as execution_id,
    CAST('pipeline_initialization' AS VARCHAR(255)) as pipeline_name,
    CURRENT_TIMESTAMP() as start_time,
    CURRENT_TIMESTAMP() as end_time,
    CAST('SUCCESS' AS VARCHAR(255)) as status,
    CAST(NULL AS VARCHAR(16777216)) as error_message,
    0 as execution_duration_seconds,
    CAST('INITIALIZATION' AS VARCHAR(255)) as source_tables_processed,
    CAST('SI_PIPELINE_AUDIT' AS VARCHAR(255)) as target_tables_updated,
    1 as records_processed,
    1 as records_inserted,
    0 as records_updated,
    0 as records_rejected,
    CURRENT_USER() as executed_by,
    CAST('PROD' AS VARCHAR(255)) as execution_environment,
    CAST('Initial audit table creation' AS VARCHAR(16777216)) as data_lineage_info,
    CURRENT_DATE() as load_date,
    CURRENT_DATE() as update_date,
    CAST('DBT_SILVER_PIPELINE' AS VARCHAR(255)) as source_system
