-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

-- Create audit table with proper column definitions
SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) as RECORD_ID,
    'AUDIT_TABLE_INITIALIZED' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    'DBT_SYSTEM' as PROCESSED_BY,
    0.0 as PROCESSING_TIME,
    'SUCCESS' as STATUS
WHERE FALSE -- This ensures no actual data is inserted, just table creation
