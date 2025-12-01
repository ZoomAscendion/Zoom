-- Bronze Layer Audit Model
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Materialization: Incremental table for performance
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='incremental',
    unique_key='record_id',
    on_schema_change='append_new_columns',
    tags=['bronze', 'audit', 'monitoring']
) }}

WITH audit_base AS (
    SELECT 
        -- Auto-incrementing record ID using dbt_utils
        {{ dbt_utils.generate_surrogate_key(['source_table', 'load_timestamp', 'processed_by']) }} AS record_id,
        
        -- Source table information
        COALESCE(source_table, 'UNKNOWN') AS source_table,
        
        -- Timestamp information
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        
        -- Processing information
        COALESCE(processed_by, 'DBT_BRONZE_PIPELINE') AS processed_by,
        COALESCE(processing_time, 0.0) AS processing_time,
        
        -- Status information
        COALESCE(status, 'UNKNOWN') AS status,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM (
        -- This will be populated by pre/post hooks from other models
        SELECT 
            CAST(NULL AS VARCHAR(255)) AS source_table,
            CAST(NULL AS TIMESTAMP_NTZ(9)) AS load_timestamp,
            CAST(NULL AS VARCHAR(255)) AS processed_by,
            CAST(NULL AS NUMBER(38,3)) AS processing_time,
            CAST(NULL AS VARCHAR(50)) AS status
        WHERE 1=0  -- This ensures no rows are selected initially
    ) base
)

SELECT 
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status,
    created_at,
    updated_at
FROM audit_base

{% if is_incremental() %}
    WHERE load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
