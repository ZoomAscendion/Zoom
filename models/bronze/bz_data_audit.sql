-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

-- Create audit table structure with sample data
SELECT 
    1 as record_id,
    'AUDIT_INITIALIZATION' as source_table,
    CURRENT_TIMESTAMP() as load_timestamp,
    'DBT_SYSTEM' as processed_by,
    0.001 as processing_time,
    'SUCCESS' as status
WHERE FALSE  -- This creates the table structure without inserting any rows initially

UNION ALL

-- Add a sample audit record
SELECT 
    1 as record_id,
    'SYSTEM_INIT' as source_table,
    CURRENT_TIMESTAMP() as load_timestamp,
    'DBT_SYSTEM' as processed_by,
    0.001 as processing_time,
    'INITIALIZED' as status
