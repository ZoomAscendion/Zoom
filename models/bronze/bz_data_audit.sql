-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

WITH audit_base AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS record_id,
        'AUDIT_INITIALIZATION' AS source_table,
        CURRENT_TIMESTAMP() AS load_timestamp,
        'DBT_BRONZE_PIPELINE' AS processed_by,
        0.001 AS processing_time,
        'SUCCESS' AS status
    WHERE 1=0  -- This ensures the table structure is created but no initial data
)

SELECT 
    record_id::NUMBER AS record_id,
    source_table::VARCHAR(255) AS source_table,
    load_timestamp::TIMESTAMP_NTZ(9) AS load_timestamp,
    processed_by::VARCHAR(255) AS processed_by,
    processing_time::NUMBER(38,3) AS processing_time,
    status::VARCHAR(50) AS status
FROM audit_base
