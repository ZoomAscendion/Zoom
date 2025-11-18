-- Bronze Layer Audit Table
-- Author: Data Engineering Team
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Version: 1.0
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT
    NULL::NUMBER as RECORD_ID,
    NULL::VARCHAR(255) as SOURCE_TABLE,
    NULL::TIMESTAMP_NTZ(9) as LOAD_TIMESTAMP,
    NULL::VARCHAR(255) as PROCESSED_BY,
    NULL::NUMBER(38,3) as PROCESSING_TIME,
    NULL::VARCHAR(50) as STATUS
WHERE 1=0  -- This creates the table structure without inserting any data
