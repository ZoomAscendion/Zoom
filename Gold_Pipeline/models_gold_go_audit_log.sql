{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['audit', 'infrastructure']
) }}

-- Audit log table for tracking model execution
-- This table runs first and has no pre/post hooks to avoid circular dependencies

SELECT 
    CAST(NULL AS VARCHAR(255)) AS audit_id,
    CAST(NULL AS VARCHAR(255)) AS model_name,
    CAST(NULL AS TIMESTAMP_NTZ) AS execution_start_time,
    CAST(NULL AS TIMESTAMP_NTZ) AS execution_end_time,
    CAST(NULL AS VARCHAR(50)) AS execution_status,
    CAST(NULL AS NUMBER) AS record_count,
    CAST(NULL AS VARCHAR(500)) AS error_message,
    CAST(NULL AS TIMESTAMP_NTZ) AS load_timestamp,
    CAST(NULL AS TIMESTAMP_NTZ) AS update_timestamp,
    CAST(NULL AS VARCHAR(100)) AS source_system
WHERE 1 = 0  -- Create empty table structure