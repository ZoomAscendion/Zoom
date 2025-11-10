-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create audit table structure
SELECT 
    -- Auto-incrementing unique identifier for each audit record
    CAST(1 AS NUMBER) AS RECORD_ID,
    
    -- Name of the Bronze layer table (VARCHAR(255) to avoid truncation)
    CAST('AUDIT_INITIALIZATION' AS VARCHAR(255)) AS SOURCE_TABLE,
    
    -- When the operation occurred
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    
    -- User or process that performed the operation
    CAST('DBT_SYSTEM' AS VARCHAR(255)) AS PROCESSED_BY,
    
    -- Time taken to process the operation in seconds
    CAST(0.0 AS NUMBER(38,3)) AS PROCESSING_TIME,
    
    -- Status of the operation (SUCCESS, FAILED, WARNING)
    CAST('SUCCESS' AS VARCHAR(50)) AS STATUS
    
WHERE FALSE  -- This ensures no actual data is inserted during model creation
