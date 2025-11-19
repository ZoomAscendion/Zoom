-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

-- Create audit table structure with auto-incrementing record_id
WITH audit_structure AS (
    SELECT 
        1 AS RECORD_ID,
        'SYSTEM_INIT' AS SOURCE_TABLE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        'DBT_SYSTEM' AS PROCESSED_BY,
        0.0 AS PROCESSING_TIME,
        'INITIALIZED' AS STATUS
    WHERE 1=0  -- This ensures no actual data is inserted during table creation
)

SELECT 
    RECORD_ID,
    SOURCE_TABLE,
    LOAD_TIMESTAMP,
    PROCESSED_BY,
    PROCESSING_TIME,
    STATUS
FROM audit_structure
