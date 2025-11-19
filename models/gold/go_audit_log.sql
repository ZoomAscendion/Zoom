{{ config(
    materialized='table'
) }}

-- Audit log table for tracking all Gold layer pipeline executions
SELECT 
    'INITIAL_SETUP' AS process_name,
    'SYSTEM' AS source_table,
    'GO_AUDIT_LOG' AS target_table,
    'COMPLETED' AS process_status,
    CURRENT_TIMESTAMP() AS start_time,
    CURRENT_TIMESTAMP() AS end_time,
    CURRENT_DATE() AS load_date,
    'DBT_GOLD_PIPELINE' AS source_system
WHERE 1=0  -- Empty table for structure
