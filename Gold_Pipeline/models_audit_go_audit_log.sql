-- =====================================================
-- AUDIT LOG MODEL
-- Project: Zoom Platform Analytics System - Gold Layer
-- Purpose: Track all Gold layer transformations and pipeline executions
-- Materialization: Table
-- Dependencies: None (runs first)
-- =====================================================

{{ config(
    materialized='table',
    tags=['audit', 'infrastructure'],
    pre_hook="{{ log('Starting audit log initialization', info=True) }}",
    post_hook="{{ log('Completed audit log initialization', info=True) }}"
) }}

-- Create audit log table structure
WITH audit_log_structure AS (
    SELECT 
        CAST(NULL AS VARCHAR(100)) AS execution_id,
        CAST(NULL AS VARCHAR(200)) AS model_name,
        CAST(NULL AS VARCHAR(50)) AS model_type,
        CAST(NULL AS TIMESTAMP_NTZ) AS execution_start_time,
        CAST(NULL AS TIMESTAMP_NTZ) AS execution_end_time,
        CAST(NULL AS NUMBER(10,2)) AS execution_duration_seconds,
        CAST(NULL AS VARCHAR(50)) AS execution_status,
        CAST(NULL AS VARCHAR(200)) AS source_tables,
        CAST(NULL AS VARCHAR(200)) AS target_table,
        CAST(NULL AS NUMBER(15,0)) AS records_processed,
        CAST(NULL AS NUMBER(15,0)) AS records_success,
        CAST(NULL AS NUMBER(15,0)) AS records_failed,
        CAST(NULL AS NUMBER(15,0)) AS records_skipped,
        CAST(NULL AS NUMBER(5,2)) AS data_quality_score_avg,
        CAST(NULL AS NUMBER(10,0)) AS error_count,
        CAST(NULL AS NUMBER(10,0)) AS warning_count,
        CAST(NULL AS VARCHAR(100)) AS execution_trigger,
        CAST(NULL AS VARCHAR(100)) AS executed_by,
        CAST(NULL AS VARIANT) AS configuration_used,
        CAST(NULL AS VARIANT) AS error_details,
        CAST(NULL AS VARIANT) AS performance_metrics,
        CAST(NULL AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(NULL AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(NULL AS VARCHAR(100)) AS source_system
    WHERE 1 = 0  -- This ensures no actual records are created initially
),

-- Initialize with system record
initial_audit_record AS (
    SELECT 
        '{{ invocation_id }}' AS execution_id,
        'go_audit_log' AS model_name,
        'audit' AS model_type,
        CURRENT_TIMESTAMP() AS execution_start_time,
        CURRENT_TIMESTAMP() AS execution_end_time,
        0.0 AS execution_duration_seconds,
        'INITIALIZED' AS execution_status,
        'SYSTEM' AS source_tables,
        'GOLD.GO_AUDIT_LOG' AS target_table,
        1 AS records_processed,
        1 AS records_success,
        0 AS records_failed,
        0 AS records_skipped,
        100.0 AS data_quality_score_avg,
        0 AS error_count,
        0 AS warning_count,
        'DBT_INITIALIZATION' AS execution_trigger,
        'SYSTEM' AS executed_by,
        PARSE_JSON('{
            "dbt_version": "1.0+",
            "project_name": "zoom_gold_pipeline",
            "target_schema": "GOLD",
            "data_quality_threshold": 80,
            "validation_status_filter": "PASSED"
        }') AS configuration_used,
        PARSE_JSON('{}') AS error_details,
        PARSE_JSON('{
            "initialization_time": "' || CURRENT_TIMESTAMP()::STRING || '",
            "warehouse": "WH_POC_ZOOM_DEV_XSMALL",
            "database": "DB_POC_ZOOM"
        }') AS performance_metrics,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'DBT_GOLD_PIPELINE' AS source_system
)

-- Union structure with initial record
SELECT * FROM audit_log_structure
UNION ALL
SELECT * FROM initial_audit_record

-- Add documentation
{{ doc("go_audit_log", "
Audit Log Model for Gold Layer Pipeline

This model creates and maintains the audit log table that tracks all transformations
in the Gold layer pipeline. It captures:

- Execution metadata (start/end times, duration, status)
- Data quality metrics (records processed, success/failure rates)
- Performance metrics (execution times, resource usage)
- Error tracking and debugging information
- Configuration and lineage information

The audit log is essential for:
- Pipeline monitoring and alerting
- Performance optimization
- Data quality tracking
- Compliance and governance
- Troubleshooting and debugging

This model runs first in the pipeline to ensure audit logging is available
for all subsequent transformations.
") }}