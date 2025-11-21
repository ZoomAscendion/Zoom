-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

WITH audit_base AS (
    SELECT 
        1 AS record_id,
        'SYSTEM_INIT' AS source_table,
        CURRENT_TIMESTAMP() AS load_timestamp,
        'SYSTEM' AS processed_by,
        0.0 AS processing_time,
        'SUCCESS' AS status
    WHERE 1=0  -- This creates an empty table with the correct structure
)

SELECT 
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_base
