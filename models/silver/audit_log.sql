{{
  config(
    materialized='incremental',
    unique_key='audit_id',
    on_schema_change='sync_all_columns'
  )
}}

WITH audit_records AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['SOURCE_TABLE', 'LOAD_TIMESTAMP']) }} AS audit_id,
        SOURCE_TABLE::VARCHAR(255) AS source_table,
        CURRENT_TIMESTAMP() AS process_start_time,
        CURRENT_TIMESTAMP() AS process_end_time,
        'SUCCESS'::VARCHAR(50) AS status,
        LOAD_TIMESTAMP,
        PROCESSED_BY::VARCHAR(255) AS processed_by,
        PROCESSING_TIME,
        RECORD_COUNT,
        ERROR_MESSAGE::VARCHAR(500) AS error_message,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'DBT_PIPELINE'::VARCHAR(100) AS source_system
    FROM {{ ref('bz_audit_records') }}
    WHERE 1=1
    {% if is_incremental() %}
        AND LOAD_TIMESTAMP > (SELECT MAX(LOAD_TIMESTAMP) FROM {{ this }})
    {% endif %}
)

SELECT * FROM audit_records
