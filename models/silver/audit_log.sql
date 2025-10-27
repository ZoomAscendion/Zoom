{{
  config(
    materialized='incremental',
    unique_key='audit_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge'
  )
}}

-- Silver Layer Audit Log Table
-- This table tracks all pipeline executions and data processing activities

WITH audit_data AS (
    SELECT 
        MD5('zoom_silver_pipeline' || CURRENT_TIMESTAMP()::VARCHAR) AS audit_id,
        'zoom_silver_pipeline' AS pipeline_name,
        CURRENT_TIMESTAMP() AS start_time,
        NULL AS end_time,
        'RUNNING' AS status,
        NULL AS error_message,
        MD5('exec_' || CURRENT_TIMESTAMP()::VARCHAR) AS execution_id,
        CURRENT_TIMESTAMP() AS execution_start_time,
        NULL AS execution_end_time,
        NULL AS execution_duration_seconds,
        'BRONZE' AS source_table,
        'SILVER' AS target_table,
        0 AS records_processed,
        0 AS records_success,
        0 AS records_failed,
        0 AS records_rejected,
        'INITIALIZED' AS execution_status,
        'DBT_SILVER_PIPELINE' AS processed_by,
        CURRENT_TIMESTAMP() AS load_timestamp
)

SELECT * FROM audit_data

{% if is_incremental() %}
  WHERE load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
