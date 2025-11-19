{{ config(
    materialized='table',
    pre_hook=none,
    post_hook=none
) }}

-- Audit log table for tracking all Gold layer pipeline executions
-- This table must be created first and runs without hooks to avoid circular dependencies

SELECT 
    'INITIAL_SETUP' AS process_name,
    'SYSTEM' AS source_table,
    'GO_AUDIT_LOG' AS target_table,
    'COMPLETED' AS process_status,
    CURRENT_TIMESTAMP() AS start_time,
    CURRENT_TIMESTAMP() AS end_time,
    CURRENT_DATE() AS load_date,
    'DBT_GOLD_PIPELINE' AS source_system
WHERE FALSE  -- This ensures no actual data is inserted during initial creation

UNION ALL

-- Create the structure for the audit log table
SELECT 
    CAST(NULL AS VARCHAR(255)) AS process_name,
    CAST(NULL AS VARCHAR(255)) AS source_table,
    CAST(NULL AS VARCHAR(255)) AS target_table,
    CAST(NULL AS VARCHAR(50)) AS process_status,
    CAST(NULL AS TIMESTAMP_NTZ) AS start_time,
    CAST(NULL AS TIMESTAMP_NTZ) AS end_time,
    CAST(NULL AS DATE) AS load_date,
    CAST(NULL AS VARCHAR(255)) AS source_system
WHERE FALSE
