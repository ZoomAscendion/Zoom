-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT
    -- Auto-incrementing unique identifier for each audit record
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS RECORD_ID,
    
    -- Name of the Bronze layer table being audited
    CAST(NULL AS VARCHAR(255)) AS SOURCE_TABLE,
    
    -- When the operation occurred
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    
    -- User or process that performed the operation
    CAST('DBT_SYSTEM' AS VARCHAR(100)) AS PROCESSED_BY,
    
    -- Time taken to process the operation in seconds
    CAST(0.0 AS NUMBER(10,3)) AS PROCESSING_TIME,
    
    -- Status of the operation (SUCCESS, FAILED, WARNING)
    CAST('INITIALIZED' AS VARCHAR(50)) AS STATUS
    
WHERE 1=0  -- This creates the table structure without inserting any rows initially
