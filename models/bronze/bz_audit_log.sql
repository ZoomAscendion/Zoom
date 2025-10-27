-- Bronze Layer Audit Log Model
-- Description: Tracks all data processing activities in the bronze layer
-- Author: DBT Data Engineer

{{ config(
    materialized='table'
) }}

SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) as record_id,
    'AUDIT_LOG_INITIALIZED'::VARCHAR(255) as source_table,
    CURRENT_TIMESTAMP() as load_timestamp,
    'DBT'::VARCHAR(100) as processed_by,
    0 as processing_time,
    'INITIALIZED'::VARCHAR(50) as status
WHERE FALSE  -- This ensures no records are inserted during initial creation
