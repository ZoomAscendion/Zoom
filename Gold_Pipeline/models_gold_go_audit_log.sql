-- =====================================================
-- AUDIT LOG TABLE
-- Model: go_audit_log
-- Purpose: Comprehensive audit trail for all Gold layer pipeline executions
-- Materialization: table
-- Dependencies: None (runs first)
-- =====================================================

{{ config(
    materialized='table',
    cluster_by=['LOAD_DATE', 'MODEL_NAME'],
    tags=['audit', 'infrastructure'],
    pre_hook=None,
    post_hook=None
) }}

-- Create audit log table structure
WITH audit_log_base AS (
    SELECT 
        -- Primary audit fields
        CAST(NULL AS VARCHAR(100)) AS EXECUTION_ID,
        CAST(NULL AS VARCHAR(200)) AS MODEL_NAME,
        CAST(NULL AS VARCHAR(100)) AS PIPELINE_TYPE,
        CAST(NULL AS TIMESTAMP_NTZ(9)) AS EXECUTION_START_TIME,
        CAST(NULL AS TIMESTAMP_NTZ(9)) AS EXECUTION_END_TIME,
        CAST(NULL AS NUMBER(10,2)) AS EXECUTION_DURATION_SECONDS,
        CAST(NULL AS VARCHAR(50)) AS EXECUTION_STATUS,
        
        -- Data processing metrics
        CAST(NULL AS VARCHAR(200)) AS SOURCE_TABLE,
        CAST(NULL AS VARCHAR(200)) AS TARGET_TABLE,
        CAST(NULL AS NUMBER(15,0)) AS RECORDS_PROCESSED,
        CAST(NULL AS NUMBER(15,0)) AS RECORDS_SUCCESS,
        CAST(NULL AS NUMBER(15,0)) AS RECORDS_FAILED,
        CAST(NULL AS NUMBER(15,0)) AS RECORDS_SKIPPED,
        CAST(NULL AS NUMBER(5,2)) AS DATA_QUALITY_SCORE_AVG,
        CAST(NULL AS NUMBER(10,0)) AS ERROR_COUNT,
        CAST(NULL AS NUMBER(10,0)) AS WARNING_COUNT,
        
        -- Execution context
        CAST(NULL AS VARCHAR(100)) AS EXECUTION_TRIGGER,
        CAST(NULL AS VARCHAR(100)) AS EXECUTED_BY,
        CAST(NULL AS VARIANT) AS CONFIGURATION_USED,
        CAST(NULL AS VARIANT) AS ERROR_DETAILS,
        CAST(NULL AS VARIANT) AS PERFORMANCE_METRICS,
        
        -- Standard metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_DATE() AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        'DBT_GOLD_PIPELINE' AS SOURCE_SYSTEM
    
    WHERE 1=0  -- This ensures no records are returned initially
)

-- Initial table creation with proper structure
SELECT 
    EXECUTION_ID,
    MODEL_NAME,
    PIPELINE_TYPE,
    EXECUTION_START_TIME,
    EXECUTION_END_TIME,
    EXECUTION_DURATION_SECONDS,
    EXECUTION_STATUS,
    SOURCE_TABLE,
    TARGET_TABLE,
    RECORDS_PROCESSED,
    RECORDS_SUCCESS,
    RECORDS_FAILED,
    RECORDS_SKIPPED,
    DATA_QUALITY_SCORE_AVG,
    ERROR_COUNT,
    WARNING_COUNT,
    EXECUTION_TRIGGER,
    EXECUTED_BY,
    CONFIGURATION_USED,
    ERROR_DETAILS,
    PERFORMANCE_METRICS,
    LOAD_DATE,
    LOAD_TIMESTAMP,
    UPDATE_DATE,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM audit_log_base

-- Add initial audit record for table creation
UNION ALL

SELECT 
    '{{ invocation_id }}' AS EXECUTION_ID,
    'go_audit_log' AS MODEL_NAME,
    'INFRASTRUCTURE' AS PIPELINE_TYPE,
    CURRENT_TIMESTAMP() AS EXECUTION_START_TIME,
    CURRENT_TIMESTAMP() AS EXECUTION_END_TIME,
    0.0 AS EXECUTION_DURATION_SECONDS,
    'COMPLETED' AS EXECUTION_STATUS,
    'N/A' AS SOURCE_TABLE,
    'GOLD.GO_AUDIT_LOG' AS TARGET_TABLE,
    1 AS RECORDS_PROCESSED,
    1 AS RECORDS_SUCCESS,
    0 AS RECORDS_FAILED,
    0 AS RECORDS_SKIPPED,
    100.0 AS DATA_QUALITY_SCORE_AVG,
    0 AS ERROR_COUNT,
    0 AS WARNING_COUNT,
    'DBT_RUN' AS EXECUTION_TRIGGER,
    '{{ target.user }}' AS EXECUTED_BY,
    PARSE_JSON('{
        "materialized": "table",
        "cluster_by": ["LOAD_DATE", "MODEL_NAME"],
        "tags": ["audit", "infrastructure"]
    }') AS CONFIGURATION_USED,
    NULL AS ERROR_DETAILS,
    PARSE_JSON('{
        "execution_time_ms": 0,
        "rows_affected": 1,
        "bytes_processed": 1024
    }') AS PERFORMANCE_METRICS,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_DATE() AS UPDATE_DATE,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    'DBT_GOLD_PIPELINE' AS SOURCE_SYSTEM