{{
  config(
    materialized='table',
    on_schema_change='sync_all_columns'
  )
}}

SELECT 
    {{ dbt_utils.generate_surrogate_key(['CURRENT_TIMESTAMP()']) }} AS audit_id,
    'INITIALIZATION'::VARCHAR(255) AS source_table,
    CURRENT_TIMESTAMP() AS process_start_time,
    CURRENT_TIMESTAMP() AS process_end_time,
    'SUCCESS'::VARCHAR(50) AS status,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_PIPELINE'::VARCHAR(255) AS processed_by,
    0 AS processing_time,
    1 AS record_count,
    'Audit log initialized'::VARCHAR(500) AS error_message,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_PIPELINE'::VARCHAR(100) AS source_system
