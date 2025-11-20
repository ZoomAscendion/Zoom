-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

-- Create audit table structure with explicit column definitions
SELECT 
    CAST(NULL AS NUMBER) as record_id,
    CAST(NULL AS VARCHAR(255)) as source_table,
    CAST(NULL AS TIMESTAMP_NTZ(9)) as load_timestamp,
    CAST(NULL AS VARCHAR(255)) as processed_by,
    CAST(NULL AS NUMBER(38,3)) as processing_time,
    CAST(NULL AS VARCHAR(255)) as status
WHERE FALSE -- This ensures no data is inserted during initial creation
