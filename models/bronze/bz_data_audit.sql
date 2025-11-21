-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['audit', 'bronze']
) }}

-- Create audit table structure
SELECT 
    CAST(NULL AS NUMBER) as RECORD_ID,
    CAST(NULL AS VARCHAR(255)) as SOURCE_TABLE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) as LOAD_TIMESTAMP,
    CAST(NULL AS VARCHAR(255)) as PROCESSED_BY,
    CAST(NULL AS NUMBER(38,3)) as PROCESSING_TIME,
    CAST(NULL AS VARCHAR(50)) as STATUS
WHERE 1=0  -- This creates an empty table with the correct structure
