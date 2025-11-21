-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook=None,
    post_hook=None
) }}

-- Create audit table with proper structure and auto-increment
WITH audit_structure AS (
    SELECT 
        1 AS record_id,
        'SYSTEM_INIT' AS source_table,
        CURRENT_TIMESTAMP() AS load_timestamp,
        'DBT_SYSTEM' AS processed_by,
        0.0 AS processing_time,
        'INITIALIZED' AS status
    WHERE 1=0  -- This ensures no data is inserted initially
)

SELECT 
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_structure
