-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team

{{ config(
    materialized='table'
) }}

-- Create audit table with initial structure
SELECT 
    1 AS record_id,
    'SYSTEM_INIT' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_SYSTEM' AS processed_by,
    0.0 AS processing_time,
    'INITIALIZED' AS status
WHERE 1=0  -- This ensures no data is inserted initially, only structure is created
