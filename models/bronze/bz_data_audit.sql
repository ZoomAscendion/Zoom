-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook=none,
    post_hook=none
) }}

WITH audit_base AS (
    SELECT 
        NULL::NUMBER AS record_id,
        NULL::VARCHAR(255) AS source_table,
        NULL::TIMESTAMP_NTZ AS load_timestamp,
        NULL::VARCHAR(255) AS processed_by,
        NULL::NUMBER(10,3) AS processing_time,
        NULL::VARCHAR(50) AS status
    WHERE 1=0  -- This ensures no data is selected, creating an empty table with the right structure
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY load_timestamp) AS record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_base
