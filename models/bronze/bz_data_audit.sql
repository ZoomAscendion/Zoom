-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: DBT Pipeline Generator
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

SELECT 
    CAST(NULL AS NUMBER) AS record_id,
    CAST(NULL AS VARCHAR(255)) AS source_table,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS load_timestamp,
    CAST(NULL AS VARCHAR(255)) AS processed_by,
    CAST(NULL AS NUMBER(38,3)) AS processing_time,
    CAST(NULL AS VARCHAR(50)) AS status
WHERE 1=0  -- This creates the table structure without any data
