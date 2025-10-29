-- Bronze Layer Audit Log Model
-- This model creates the audit log table that tracks all data processing activities
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

-- Create audit log table structure with proper data types
SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) as RECORD_ID,
    'AUDIT_LOG_INITIALIZATION' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as PROCESS_START_TIME,
    CURRENT_TIMESTAMP() as PROCESS_END_TIME,
    'SUCCESS' as STATUS,
    0 as RECORD_COUNT,
    NULL as ERROR_MESSAGE,
    'DBT_SYSTEM' as PROCESSED_BY,
    CURRENT_TIMESTAMP() as CREATED_TIMESTAMP
WHERE 1=1
LIMIT 1
