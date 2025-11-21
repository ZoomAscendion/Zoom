-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: DBT Data Engineer

{{ config(
    materialized='table'
) }}

SELECT 
    1 AS record_id,
    'INITIAL_SETUP' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_SYSTEM' AS processed_by,
    0.0 AS processing_time,
    'SUCCESS' AS status
WHERE 1=0  -- This creates the table structure but with no data initially

UNION ALL

SELECT 
    2 AS record_id,
    'AUDIT_TABLE_CREATED' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_SYSTEM' AS processed_by,
    0.1 AS processing_time,
    'SUCCESS' AS status
