/*
  Model: go_process_audit
  Author: Data Engineering Team
  Created: 2024-12-19
  Description: Audit log table for tracking all Gold layer pipeline executions and processes
  
  This model creates the audit table that runs FIRST before all other models
  to ensure audit logging is available for all transformations.
  
  Dependencies: None (runs first)
  Materialization: Table
  Clustering: EXECUTION_START_TIMESTAMP
*/

{{ config(
    materialized='table',
    cluster_by=['EXECUTION_START_TIMESTAMP', 'PROCESS_NAME'],
    tags=['audit', 'gold_layer', 'infrastructure'],
    pre_hook=none,
    post_hook=none,
    on_schema_change='fail'
) }}

-- Create the audit log table structure
SELECT 
    -- Primary audit fields
    CAST(NULL AS VARCHAR(50)) AS AUDIT_LOG_ID,
    CAST(NULL AS VARCHAR(200)) AS PROCESS_NAME,
    CAST(NULL AS VARCHAR(100)) AS PROCESS_TYPE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS EXECUTION_START_TIMESTAMP,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS EXECUTION_END_TIMESTAMP,
    CAST(NULL AS NUMBER(15,2)) AS EXECUTION_DURATION_SECONDS,
    CAST(NULL AS VARCHAR(50)) AS EXECUTION_STATUS,
    
    -- Table information
    CAST(NULL AS VARCHAR(200)) AS SOURCE_TABLE_NAME,
    CAST(NULL AS VARCHAR(200)) AS TARGET_TABLE_NAME,
    
    -- Record counts and metrics
    CAST(NULL AS NUMBER(20,0)) AS RECORDS_READ,
    CAST(NULL AS NUMBER(20,0)) AS RECORDS_PROCESSED,
    CAST(NULL AS NUMBER(20,0)) AS RECORDS_INSERTED,
    CAST(NULL AS NUMBER(20,0)) AS RECORDS_UPDATED,
    CAST(NULL AS NUMBER(20,0)) AS RECORDS_FAILED,
    
    -- Data quality metrics
    CAST(NULL AS NUMBER(5,2)) AS DATA_QUALITY_SCORE,
    CAST(NULL AS NUMBER(15,0)) AS ERROR_COUNT,
    CAST(NULL AS NUMBER(15,0)) AS WARNING_COUNT,
    
    -- Execution context
    CAST(NULL AS VARCHAR(100)) AS PROCESS_TRIGGER,
    CAST(NULL AS VARCHAR(100)) AS EXECUTED_BY,
    CAST(NULL AS VARCHAR(100)) AS SERVER_NAME,
    CAST(NULL AS VARCHAR(50)) AS PROCESS_VERSION,
    
    -- Configuration and performance
    CAST(NULL AS VARIANT) AS CONFIGURATION_PARAMETERS,
    CAST(NULL AS VARIANT) AS PERFORMANCE_METRICS,
    CAST(NULL AS VARIANT) AS ERROR_DETAILS,
    
    -- Standard metadata columns
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'DBT_AUDIT_INFRASTRUCTURE' AS SOURCE_SYSTEM
    
WHERE 1 = 0  -- This ensures no rows are inserted during initial creation

-- Add initial system record to indicate audit table is ready
UNION ALL

SELECT 
    '{{ invocation_id }}' AS AUDIT_LOG_ID,
    'AUDIT_TABLE_INITIALIZATION' AS PROCESS_NAME,
    'INFRASTRUCTURE' AS PROCESS_TYPE,
    CURRENT_TIMESTAMP() AS EXECUTION_START_TIMESTAMP,
    CURRENT_TIMESTAMP() AS EXECUTION_END_TIMESTAMP,
    0.0 AS EXECUTION_DURATION_SECONDS,
    'SUCCESS' AS EXECUTION_STATUS,
    
    'NONE' AS SOURCE_TABLE_NAME,
    'GO_PROCESS_AUDIT' AS TARGET_TABLE_NAME,
    
    0 AS RECORDS_READ,
    1 AS RECORDS_PROCESSED,
    1 AS RECORDS_INSERTED,
    0 AS RECORDS_UPDATED,
    0 AS RECORDS_FAILED,
    
    100.0 AS DATA_QUALITY_SCORE,
    0 AS ERROR_COUNT,
    0 AS WARNING_COUNT,
    
    'DBT_INITIALIZATION' AS PROCESS_TRIGGER,
    '{{ target.user }}' AS EXECUTED_BY,
    '{{ target.name }}' AS SERVER_NAME,
    '1.0.0' AS PROCESS_VERSION,
    
    PARSE_JSON('{
        "dbt_version": "{{ dbt_version }}",
        "target_name": "{{ target.name }}",
        "target_schema": "{{ target.schema }}",
        "invocation_id": "{{ invocation_id }}",
        "run_started_at": "{{ run_started_at }}"
    }') AS CONFIGURATION_PARAMETERS,
    
    PARSE_JSON('{
        "initialization_time_ms": 0,
        "memory_usage_mb": 0,
        "cpu_usage_percent": 0
    }') AS PERFORMANCE_METRICS,
    
    PARSE_JSON('{}') AS ERROR_DETAILS,
    
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'DBT_AUDIT_INFRASTRUCTURE' AS SOURCE_SYSTEM