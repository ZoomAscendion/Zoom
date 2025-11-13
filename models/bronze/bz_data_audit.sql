-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS record_id,
    'AUDIT_INITIALIZATION' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_SYSTEM' AS processed_by,
    0.0 AS processing_time,
    'SUCCESS' AS status
WHERE FALSE -- This ensures no actual data is inserted during initial creation
