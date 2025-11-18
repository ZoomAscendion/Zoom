-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

-- Create audit table with auto-incrementing RECORD_ID
SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) as RECORD_ID,
    'AUDIT_INIT'::VARCHAR(255) as SOURCE_TABLE,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ(9) as LOAD_TIMESTAMP,
    'DBT_SYSTEM'::VARCHAR(255) as PROCESSED_BY,
    0.0::NUMBER(38,3) as PROCESSING_TIME,
    'INITIALIZED'::VARCHAR(50) as STATUS
WHERE 1=0  -- Create empty table structure but with proper schema

UNION ALL

-- Add initial audit record
SELECT 
    1 as RECORD_ID,
    'BZ_DATA_AUDIT' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    'DBT_SYSTEM' as PROCESSED_BY,
    0.001 as PROCESSING_TIME,
    'CREATED' as STATUS
