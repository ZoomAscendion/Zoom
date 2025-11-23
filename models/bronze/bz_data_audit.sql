{{
  config(
    materialized='table',
    tags=['bronze', 'audit']
  )
}}

-- Audit table for comprehensive tracking of all Bronze layer data operations
-- This table tracks all data processing activities in the Bronze layer

SELECT
    -- Auto-incrementing record ID will be handled by Snowflake AUTOINCREMENT
    CAST(NULL AS NUMBER) AS record_id,
    CAST(NULL AS VARCHAR(255)) AS source_table,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS load_timestamp,
    CAST(NULL AS VARCHAR(255)) AS processed_by,
    CAST(NULL AS NUMBER(38,3)) AS processing_time,
    CAST(NULL AS VARCHAR(50)) AS status
WHERE 1=0  -- This creates the table structure without any data
