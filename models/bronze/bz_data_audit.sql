-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

WITH audit_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) as record_id,
        'SYSTEM_INIT' as source_table,
        CURRENT_TIMESTAMP() as load_timestamp,
        'DBT_SYSTEM' as processed_by,
        0.0 as processing_time,
        'INITIALIZED' as status
    WHERE FALSE  -- This ensures no actual data is inserted during initial creation
)

SELECT 
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_data
