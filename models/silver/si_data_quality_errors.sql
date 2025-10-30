{{ config(
    materialized='incremental',
    unique_key='error_id',
    on_schema_change='sync_all_columns'
) }}

-- Data Quality Errors tracking table
WITH error_records AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['source_table', 'source_record_id', 'error_type']) }} as error_id,
        'SAMPLE_TABLE' as source_table,
        'SAMPLE_RECORD' as source_record_id,
        'Missing Value' as error_type,
        'SAMPLE_COLUMN' as error_column,
        'Sample error for initialization' as error_description,
        'Low' as error_severity,
        CURRENT_TIMESTAMP() as detected_timestamp,
        'Open' as resolution_status,
        NULL as resolution_action,
        NULL as resolved_timestamp,
        NULL as resolved_by,
        CURRENT_DATE() as load_date,
        CURRENT_DATE() as update_date,
        'DBT_SILVER_PIPELINE' as source_system
    WHERE FALSE  -- This ensures no actual records are inserted during initialization
)

SELECT 
    error_id,
    source_table,
    source_record_id,
    error_type,
    error_column,
    error_description,
    error_severity,
    detected_timestamp,
    resolution_status,
    resolution_action,
    resolved_timestamp,
    resolved_by,
    load_date,
    update_date,
    source_system
FROM error_records

{% if is_incremental() %}
    WHERE detected_timestamp > (SELECT MAX(detected_timestamp) FROM {{ this }})
{% endif %}
