-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT 
    -- Auto-incrementing record ID will be handled by Snowflake AUTOINCREMENT
    NULL::NUMBER as RECORD_ID,
    'INITIAL_SETUP'::VARCHAR(255) as SOURCE_TABLE,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ(9) as LOAD_TIMESTAMP,
    'DBT_SYSTEM'::VARCHAR(255) as PROCESSED_BY,
    0.001::NUMBER(38,3) as PROCESSING_TIME,
    'SUCCESS'::VARCHAR(255) as STATUS
WHERE 1=0  -- This creates the table structure without inserting any initial records
