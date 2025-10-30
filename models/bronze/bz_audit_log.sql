-- Bronze Layer Audit Log Model
-- This model creates the audit log table for tracking data processing activities
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="
        CREATE TABLE IF NOT EXISTS {{ this }} (
            RECORD_ID NUMBER AUTOINCREMENT,
            SOURCE_TABLE VARCHAR(255),
            LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
            PROCESSED_BY VARCHAR(50),
            PROCESSING_TIME NUMBER(10,3),
            STATUS VARCHAR(50),
            RECORD_COUNT NUMBER(38,0),
            ERROR_MESSAGE VARCHAR(16777216),
            CREATED_TIMESTAMP TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
        )
    "
) }}

-- This model creates the audit log structure
-- The actual table is created via pre-hook to ensure it exists before other models run
SELECT 
    1 as RECORD_ID,
    'AUDIT_LOG_INIT' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    'DBT_SYS' as PROCESSED_BY,
    0.001 as PROCESSING_TIME,
    'SUCCESS' as STATUS,
    0 as RECORD_COUNT,
    NULL as ERROR_MESSAGE,
    CURRENT_TIMESTAMP() as CREATED_TIMESTAMP
WHERE FALSE -- This ensures no actual data is inserted, just structure creation
