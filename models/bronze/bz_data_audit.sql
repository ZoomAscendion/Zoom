-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create audit table structure with explicit column definitions
WITH audit_structure AS (
    SELECT 
        1 AS RECORD_ID,
        'INITIALIZATION' AS SOURCE_TABLE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        'DBT_SYSTEM' AS PROCESSED_BY,
        0.0 AS PROCESSING_TIME,
        'INITIALIZED' AS STATUS
    WHERE 1=0  -- This ensures no actual records are inserted during initialization
)

SELECT 
    RECORD_ID,
    SOURCE_TABLE,
    LOAD_TIMESTAMP,
    PROCESSED_BY,
    PROCESSING_TIME,
    STATUS
FROM audit_structure
