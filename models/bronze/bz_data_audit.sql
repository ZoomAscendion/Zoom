-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create audit table structure
SELECT 
    1::NUMBER as record_id,
    'SYSTEM_INIT'::VARCHAR(255) as source_table,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ(9) as load_timestamp,
    'DBT_SYSTEM'::VARCHAR(255) as processed_by,
    0.0::NUMBER(10,3) as processing_time,
    'INITIALIZED'::VARCHAR(50) as status
WHERE 1=0  -- Creates empty table with proper structure
