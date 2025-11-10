/*
  go_audit_log.sql
  Zoom Platform Analytics System - Gold Layer Audit Log
  
  Author: Data Engineering Team
  Description: Comprehensive audit log table for tracking all Gold layer pipeline executions
  
  This model creates the audit log table that tracks execution metadata for all other models.
  It runs first and has no hooks to prevent recursive execution.
*/

{{ config(
    materialized='table',
    pre_hook=[],
    post_hook=[],
    tags=['audit', 'infrastructure']
) }}

-- Create audit log table structure
WITH audit_log_structure AS (
    SELECT 
        CAST(NULL AS VARCHAR(255)) AS execution_id,
        CAST(NULL AS VARCHAR(255)) AS model_name,
        CAST(NULL AS TIMESTAMP_NTZ) AS execution_start_time,
        CAST(NULL AS TIMESTAMP_NTZ) AS execution_end_time,
        CAST(NULL AS NUMBER(10,2)) AS execution_duration_seconds,
        CAST(NULL AS VARCHAR(50)) AS execution_status,
        CAST(NULL AS VARCHAR(255)) AS source_table,
        CAST(NULL AS VARCHAR(255)) AS target_table,
        CAST(NULL AS NUMBER(38,0)) AS records_processed,
        CAST(NULL AS NUMBER(38,0)) AS records_success,
        CAST(NULL AS NUMBER(38,0)) AS records_failed,
        CAST(NULL AS NUMBER(38,0)) AS records_skipped,
        CAST(NULL AS NUMBER(5,2)) AS data_quality_score_avg,
        CAST(NULL AS NUMBER(38,0)) AS error_count,
        CAST(NULL AS NUMBER(38,0)) AS warning_count,
        CAST(NULL AS VARCHAR(100)) AS execution_trigger,
        CAST(NULL AS VARCHAR(255)) AS executed_by,
        CAST(NULL AS VARIANT) AS configuration_used,
        CAST(NULL AS VARIANT) AS error_details,
        CAST(NULL AS VARIANT) AS performance_metrics,
        CAST(NULL AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(NULL AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(NULL AS VARCHAR(100)) AS source_system
    WHERE 1 = 0  -- This ensures no rows are returned, creating empty table structure
)

-- Initialize with system record
SELECT 
    '{{ invocation_id }}' AS execution_id,
    'go_audit_log' AS model_name,
    CURRENT_TIMESTAMP AS execution_start_time,
    CURRENT_TIMESTAMP AS execution_end_time,
    0.0 AS execution_duration_seconds,
    'INITIALIZED' AS execution_status,
    'SYSTEM' AS source_table,
    'go_audit_log' AS target_table,
    1 AS records_processed,
    1 AS records_success,
    0 AS records_failed,
    0 AS records_skipped,
    100.0 AS data_quality_score_avg,
    0 AS error_count,
    0 AS warning_count,
    'DBT_INITIALIZATION' AS execution_trigger,
    'SYSTEM' AS executed_by,
    PARSE_JSON('{"model": "go_audit_log", "materialized": "table"}') AS configuration_used,
    PARSE_JSON('{}') AS error_details,
    PARSE_JSON('{"initialization_time": "' || CURRENT_TIMESTAMP || '"}') AS performance_metrics,
    CURRENT_TIMESTAMP AS load_timestamp,
    CURRENT_TIMESTAMP AS update_timestamp,
    'DBT_GOLD_PIPELINE' AS source_system

UNION ALL

SELECT * FROM audit_log_structure