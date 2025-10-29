-- Bronze Layer Audit Log Model
-- This model creates the audit log table that tracks all data processing activities
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table'
) }}

-- Create audit log table structure
SELECT 
    CAST(NULL AS NUMBER) as RECORD_ID,
    CAST(NULL AS VARCHAR(255)) as SOURCE_TABLE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) as PROCESS_START_TIME,
    CAST(NULL AS TIMESTAMP_NTZ(9)) as PROCESS_END_TIME,
    CAST(NULL AS VARCHAR(50)) as STATUS,
    CAST(NULL AS NUMBER(38,0)) as RECORD_COUNT,
    CAST(NULL AS VARCHAR(16777216)) as ERROR_MESSAGE,
    CAST(NULL AS VARCHAR(255)) as PROCESSED_BY,
    CURRENT_TIMESTAMP() as CREATED_TIMESTAMP
WHERE FALSE -- This ensures no actual data is inserted, just table creation
