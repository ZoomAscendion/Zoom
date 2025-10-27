-- Bronze Layer Audit Log Model
-- Description: Tracks all data processing activities in the bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook=None,
    post_hook=None
) }}

WITH audit_base AS (
    SELECT 
        -- Auto-incrementing record ID will be handled by Snowflake AUTOINCREMENT
        NULL as record_id,
        'INITIAL_LOAD' as source_table,
        CURRENT_TIMESTAMP() as load_timestamp,
        'DBT' as processed_by,
        0 as processing_time,
        'INITIALIZED' as status
    WHERE 1=0  -- This ensures no records are inserted during initial creation
)

SELECT 
    record_id,
    source_table::VARCHAR(255) as source_table,
    load_timestamp,
    processed_by::VARCHAR(100) as processed_by,
    processing_time,
    status::VARCHAR(50) as status
FROM audit_base
