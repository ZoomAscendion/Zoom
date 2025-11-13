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
    CAST('AUDIT_INIT' AS VARCHAR(255)) AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CAST('DBT' AS VARCHAR(255)) AS processed_by,
    0.0 AS processing_time,
    CAST('SUCCESS' AS VARCHAR(255)) AS status
WHERE FALSE -- This ensures no actual data is inserted during initial creation
