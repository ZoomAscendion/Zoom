{{ config(
    materialized='incremental',
    unique_key='execution_id',
    on_schema_change='sync_all_columns'
) }}

-- Audit table for tracking Silver layer pipeline execution
WITH audit_base AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(["'audit_base'", "current_timestamp()"]) }} AS execution_id,
        'Silver Pipeline Audit Base' AS pipeline_name,
        CURRENT_TIMESTAMP() AS start_time,
        CURRENT_TIMESTAMP() AS end_time,
        'Success' AS status,
        NULL AS error_message,
        0 AS execution_duration_seconds,
        'BRONZE Layer Tables' AS source_tables_processed,
        'SILVER Layer Tables' AS target_tables_updated,
        0 AS records_processed,
        0 AS records_inserted,
        0 AS records_updated,
        0 AS records_rejected,
        'DBT_SYSTEM' AS executed_by,
        'PROD' AS execution_environment,
        'Audit table initialization' AS data_lineage_info,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'Pipeline Audit System' AS source_system
    
    {% if is_incremental() %}
    WHERE FALSE  -- Don't insert base record on incremental runs
    {% endif %}
)

SELECT * FROM audit_base
