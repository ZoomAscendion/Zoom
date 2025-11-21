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
        CAST(ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS NUMBER) AS record_id,
        CAST('INITIAL_SETUP' AS VARCHAR(255)) AS source_table,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CAST('DBT_SYSTEM' AS VARCHAR(255)) AS processed_by,
        CAST(0.0 AS NUMBER(38,3)) AS processing_time,
        CAST('INITIALIZED' AS VARCHAR(50)) AS status
    WHERE 1=0  -- This ensures the table structure is created but no data is inserted initially
)

SELECT 
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_base
