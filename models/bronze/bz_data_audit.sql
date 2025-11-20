-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

-- Create audit table structure with auto-incrementing record_id
SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS RECORD_ID,
    CAST('SYSTEM_INIT' AS VARCHAR(255)) AS SOURCE_TABLE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)) AS PROCESSED_BY,
    CAST(0.0 AS NUMBER(38,3)) AS PROCESSING_TIME,
    CAST('INITIALIZED' AS VARCHAR(50)) AS STATUS
WHERE 1=0  -- This creates the table structure without inserting any data
