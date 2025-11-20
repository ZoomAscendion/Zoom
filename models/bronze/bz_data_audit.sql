-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

CREATE TABLE IF NOT EXISTS {{ this }} (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE VARCHAR(255),
    LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
    PROCESSED_BY VARCHAR(255),
    PROCESSING_TIME NUMBER(38,3),
    STATUS VARCHAR(50)
);

-- This model creates the audit table structure
-- The actual audit records are inserted via pre/post hooks in other models
SELECT 
    1 as RECORD_ID,
    'AUDIT_TABLE_INITIALIZED' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    'DBT_SYSTEM' as PROCESSED_BY,
    0.0 as PROCESSING_TIME,
    'SUCCESS' as STATUS
WHERE FALSE -- This ensures no actual data is inserted, just table creation
