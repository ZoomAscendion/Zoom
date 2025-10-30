{{ config(
    materialized='incremental',
    unique_key='audit_id',
    on_schema_change='sync_all_columns'
) }}

-- Audit log table for tracking all Silver layer processing
WITH audit_records AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['table_name', 'process_start_time']) }} as audit_id,
        CAST('INITIAL_LOAD' AS VARCHAR(255)) as table_name,
        CURRENT_TIMESTAMP() as process_start_time,
        CURRENT_TIMESTAMP() as process_end_time,
        CAST('COMPLETED' AS VARCHAR(50)) as status,
        0 as records_processed,
        CURRENT_TIMESTAMP() as created_at,
        CURRENT_TIMESTAMP() as updated_at
    WHERE FALSE -- This ensures no records are selected initially
)

SELECT 
    audit_id,
    table_name,
    process_start_time,
    process_end_time,
    status,
    records_processed,
    created_at,
    updated_at
FROM audit_records

{% if is_incremental() %}
    WHERE process_start_time > (SELECT COALESCE(MAX(process_start_time), '1900-01-01') FROM {{ this }})
{% endif %}
