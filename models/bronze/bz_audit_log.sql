-- Bronze Layer Audit Log Model
-- This model creates the audit log table for tracking data processing activities
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create audit log for tracking bronze layer data processing
SELECT 
    1 as RECORD_ID,
    'AUDIT_INIT' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    'DBT_SYS' as PROCESSED_BY,
    0.001 as PROCESSING_TIME,
    'SUCCESS' as STATUS,
    0 as RECORD_COUNT,
    NULL as ERROR_MESSAGE,
    CURRENT_TIMESTAMP() as CREATED_TIMESTAMP
WHERE 1=0 -- Empty table for structure
