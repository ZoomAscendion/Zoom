-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT 
    1 as RECORD_ID,
    'INITIAL_SETUP' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    'DBT_SYSTEM' as PROCESSED_BY,
    0.0 as PROCESSING_TIME,
    'INITIALIZED' as STATUS
WHERE 1=0  -- This creates an empty table with the correct structure
