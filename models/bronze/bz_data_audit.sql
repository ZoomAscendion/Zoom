{{
  config(
    materialized='table',
    tags=['bronze', 'audit']
  )
}}

-- Bronze Layer Audit Table
-- This table tracks all data processing operations in the Bronze layer
-- No pre-hook or post-hook for audit table to prevent circular dependencies

SELECT 
    CAST(NULL AS NUMBER) AS RECORD_ID,
    CAST(NULL AS VARCHAR(255)) AS SOURCE_TABLE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(NULL AS VARCHAR(255)) AS PROCESSED_BY,
    CAST(NULL AS NUMBER(38,3)) AS PROCESSING_TIME,
    CAST(NULL AS VARCHAR(50)) AS STATUS
WHERE 1=0  -- Create empty table with proper structure
