-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

SELECT 
    1 as record_id,
    'AUDIT_INITIALIZATION' as source_table,
    CURRENT_TIMESTAMP() as load_timestamp,
    'DBT_SYSTEM' as processed_by,
    0.001 as processing_time,
    'SUCCESS' as status
WHERE FALSE -- This ensures the table is created but empty initially
