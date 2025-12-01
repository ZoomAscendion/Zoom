-- Bronze Data Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create audit table structure with sample data for initialization
SELECT 
    1 as RECORD_ID,
    'INITIALIZATION' as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    'DBT_SYSTEM' as PROCESSED_BY,
    0.001 as PROCESSING_TIME,
    'SUCCESS' as STATUS
WHERE FALSE -- This ensures the table is created but empty initially

UNION ALL

-- Add proper column structure
SELECT 
    CAST(NULL AS NUMBER) as RECORD_ID,
    CAST(NULL AS VARCHAR(255)) as SOURCE_TABLE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) as LOAD_TIMESTAMP,
    CAST(NULL AS VARCHAR(255)) as PROCESSED_BY,
    CAST(NULL AS NUMBER(38,3)) as PROCESSING_TIME,
    CAST(NULL AS VARCHAR(50)) as STATUS
WHERE FALSE
