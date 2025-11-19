{{ config(
    materialized='table',
    schema='gold',
    tags=['audit', 'infrastructure'],
    unique_key='audit_id'
) }}

-- Audit log table for tracking all Gold layer transformations
-- This table must be created first as other models reference it in hooks

WITH audit_log_base AS (
    SELECT 
        -- Generate unique audit ID
        {{ dbt_utils.generate_surrogate_key(['CURRENT_TIMESTAMP()', 'CURRENT_USER()', 'CURRENT_SESSION()']) }} AS audit_id,
        
        -- Table and operation details
        'go_audit_log' AS table_name,
        'INITIAL_SETUP' AS operation_type,
        CURRENT_TIMESTAMP() AS operation_timestamp,
        0 AS record_count,
        
        -- User and session context
        CURRENT_USER() AS user_name,
        CURRENT_SESSION() AS session_id,
        'DBT_GOLD_PIPELINE' AS source_system,
        
        -- Additional audit fields
        NULL AS error_message,
        'SUCCESS' AS operation_status,
        0 AS duration_seconds,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_USER() AS created_by,
        '{{ var("source_system") }}' AS pipeline_source
        
    WHERE 1=0  -- This ensures the initial table is empty but has the correct structure
)

SELECT 
    CAST(audit_id AS VARCHAR(255)) AS audit_id,
    CAST(table_name AS VARCHAR(255)) AS table_name,
    CAST(operation_type AS VARCHAR(100)) AS operation_type,
    operation_timestamp,
    record_count,
    CAST(user_name AS VARCHAR(255)) AS user_name,
    CAST(session_id AS VARCHAR(255)) AS session_id,
    CAST(source_system AS VARCHAR(255)) AS source_system,
    CAST(error_message AS VARCHAR(1000)) AS error_message,
    CAST(operation_status AS VARCHAR(50)) AS operation_status,
    duration_seconds,
    created_at,
    CAST(created_by AS VARCHAR(255)) AS created_by,
    CAST(pipeline_source AS VARCHAR(255)) AS pipeline_source
FROM audit_log_base