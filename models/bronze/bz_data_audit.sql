-- Bronze Data Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create audit table structure with proper column definitions
SELECT 
    1 as RECORD_ID,
    'INITIALIZATION' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    'DBT_SYSTEM' as PROCESSED_BY,
    0.001 as PROCESSING_TIME,
    'SUCCESS' as STATUS
WHERE FALSE -- This ensures the table is created but empty initially
