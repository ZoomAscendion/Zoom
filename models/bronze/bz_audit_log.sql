-- Bronze Layer Audit Log Model
-- This model creates the audit log table that tracks all data processing activities
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    pre_hook="""
        CREATE TABLE IF NOT EXISTS {{ this }} (
            RECORD_ID NUMBER AUTOINCREMENT,
            SOURCE_TABLE VARCHAR(255),
            PROCESS_START_TIME TIMESTAMP_NTZ(9),
            PROCESS_END_TIME TIMESTAMP_NTZ(9),
            STATUS VARCHAR(50),
            RECORD_COUNT NUMBER(38,0),
            ERROR_MESSAGE VARCHAR(16777216),
            PROCESSED_BY VARCHAR(255),
            CREATED_TIMESTAMP TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
        )
    """
) }}

-- This model creates the audit log structure
-- The actual audit entries are inserted via post-hooks in other models
SELECT 
    1 as RECORD_ID,
    'INITIALIZATION' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as PROCESS_START_TIME,
    CURRENT_TIMESTAMP() as PROCESS_END_TIME,
    'SUCCESS' as STATUS,
    0 as RECORD_COUNT,
    NULL as ERROR_MESSAGE,
    'DBT_SYSTEM' as PROCESSED_BY,
    CURRENT_TIMESTAMP() as CREATED_TIMESTAMP
WHERE FALSE -- This ensures no actual data is inserted, just table creation
