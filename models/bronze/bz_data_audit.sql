-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: DBT Bronze Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook=none,
    post_hook=none
) }}

WITH audit_base AS (
    SELECT 
        -- Auto-incrementing record ID will be handled by Snowflake AUTOINCREMENT
        CAST(NULL AS NUMBER) AS record_id,
        CAST('INITIAL_SETUP' AS VARCHAR(255)) AS source_table,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)) AS processed_by,
        CAST(0 AS NUMBER(38,3)) AS processing_time,
        CAST('COMPLETED' AS VARCHAR(50)) AS status
    WHERE FALSE -- This ensures no initial records are inserted
)

SELECT 
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_base
