-- Bronze layer audit table for tracking all data operations
-- Author: AAVA Data Engineering Team
-- Created: 2024-12-19
-- Description: Comprehensive audit trail for Bronze layer data operations

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT 
    -- Auto-incrementing record ID will be handled by Snowflake AUTOINCREMENT
    NULL as RECORD_ID,
    CAST(NULL AS VARCHAR(255)) as SOURCE_TABLE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) as LOAD_TIMESTAMP,
    CAST(NULL AS VARCHAR(16777216)) as PROCESSED_BY,
    CAST(NULL AS NUMBER(38,3)) as PROCESSING_TIME,
    CAST(NULL AS VARCHAR(16777216)) as STATUS
WHERE 1=0  -- This creates the table structure without inserting any data
