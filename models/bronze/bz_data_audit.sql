-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

-- Create audit table structure with auto-increment record_id
SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) as record_id,
    'AUDIT_INITIALIZATION'::VARCHAR(255) as source_table,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ(9) as load_timestamp,
    'DBT_BRONZE_PIPELINE'::VARCHAR(255) as processed_by,
    0.0::NUMBER(38,3) as processing_time,
    'INITIALIZED'::VARCHAR(255) as status
WHERE FALSE -- This ensures no actual records are inserted during model creation
