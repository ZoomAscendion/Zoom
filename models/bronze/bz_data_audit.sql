-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

-- Create audit log table with explicit column definitions and auto-increment
SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS record_id,
    CAST('INITIAL_SETUP' AS VARCHAR(255)) AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)) AS processed_by,
    CAST(0.0 AS NUMBER(38,3)) AS processing_time,
    CAST('SUCCESS' AS VARCHAR(50)) AS status
WHERE 1=0  -- This creates the table structure without any data
