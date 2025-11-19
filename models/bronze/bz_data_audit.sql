-- Bronze Layer Audit Table Model
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

-- Create audit table with proper structure
WITH audit_structure AS (
    SELECT 
        1 AS record_id,
        'SAMPLE_TABLE' AS source_table,
        CURRENT_TIMESTAMP() AS load_timestamp,
        'dbt_user' AS processed_by,
        0.0 AS processing_time,
        'SUCCESS' AS status
    WHERE FALSE  -- This ensures no actual data is inserted initially
)

SELECT 
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_structure
