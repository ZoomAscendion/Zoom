-- =====================================================
-- GOLD LAYER AUDIT LOG MODEL
-- Model: go_audit_log
-- Purpose: Comprehensive audit trail for all Gold layer pipeline executions and processes
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- =====================================================

{{
  config(
    materialized='table',
    database='DB_POC_ZOOM',
    schema='GOLD',
    alias='GO_PROCESS_AUDIT_LOG',
    tags=['audit', 'gold_layer', 'process_tracking'],
    cluster_by=['EXECUTION_START_TIMESTAMP', 'PROCESS_NAME'],
    comment='Comprehensive audit trail for all Gold layer pipeline executions and processes'
  )
}}

-- =====================================================
-- AUDIT LOG INITIALIZATION
-- =====================================================

WITH audit_log_base AS (
  SELECT 
    -- Primary audit fields
    {{ dbt_utils.generate_surrogate_key(['CURRENT_TIMESTAMP()', "'INITIAL_LOAD'", "'SYSTEM'"]) }} AS AUDIT_LOG_ID,
    'GOLD_PIPELINE_INITIALIZATION' AS PROCESS_NAME,
    'SYSTEM_INITIALIZATION' AS PROCESS_TYPE,
    CURRENT_TIMESTAMP() AS EXECUTION_START_TIMESTAMP,
    CURRENT_TIMESTAMP() AS EXECUTION_END_TIMESTAMP,
    0.0 AS EXECUTION_DURATION_SECONDS,
    'SUCCESS' AS EXECUTION_STATUS,
    
    -- Table information
    'SYSTEM' AS SOURCE_TABLE_NAME,
    'GOLD.GO_PROCESS_AUDIT_LOG' AS TARGET_TABLE_NAME,
    
    -- Record counts
    1 AS RECORDS_READ,
    1 AS RECORDS_PROCESSED,
    1 AS RECORDS_INSERTED,
    0 AS RECORDS_UPDATED,
    0 AS RECORDS_FAILED,
    
    -- Quality and error metrics
    100.0 AS DATA_QUALITY_SCORE,
    0 AS ERROR_COUNT,
    0 AS WARNING_COUNT,
    
    -- Execution context
    'SYSTEM_INITIALIZATION' AS PROCESS_TRIGGER,
    'DBT_GOLD_PIPELINE' AS EXECUTED_BY,
    'SNOWFLAKE_COMPUTE' AS SERVER_NAME,
    '1.0.0' AS PROCESS_VERSION,
    
    -- Configuration and metrics (JSON format)
    PARSE_JSON('{
      "dbt_version": "1.0.0",
      "project_name": "zoom_gold_pipeline",
      "target_database": "DB_POC_ZOOM",
      "target_schema": "GOLD",
      "initialization_type": "AUDIT_LOG_SETUP"
    }') AS CONFIGURATION_PARAMETERS,
    
    PARSE_JSON('{
      "execution_time_ms": 0,
      "memory_usage_mb": 0,
      "cpu_usage_percent": 0,
      "warehouse_size": "XSMALL",
      "cluster_count": 1
    }') AS PERFORMANCE_METRICS,
    
    -- Standard metadata
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'DBT_GOLD_PIPELINE' AS SOURCE_SYSTEM
    
  WHERE 1=1
),

-- =====================================================
-- AUDIT LOG STRUCTURE VALIDATION
-- =====================================================

audit_log_validated AS (
  SELECT 
    -- Ensure all required fields are present and valid
    COALESCE(AUDIT_LOG_ID, {{ dbt_utils.generate_surrogate_key(['CURRENT_TIMESTAMP()']) }}) AS AUDIT_LOG_ID,
    COALESCE(PROCESS_NAME, 'UNKNOWN_PROCESS') AS PROCESS_NAME,
    COALESCE(PROCESS_TYPE, 'UNKNOWN_TYPE') AS PROCESS_TYPE,
    COALESCE(EXECUTION_START_TIMESTAMP, CURRENT_TIMESTAMP()) AS EXECUTION_START_TIMESTAMP,
    COALESCE(EXECUTION_END_TIMESTAMP, CURRENT_TIMESTAMP()) AS EXECUTION_END_TIMESTAMP,
    COALESCE(EXECUTION_DURATION_SECONDS, 0.0) AS EXECUTION_DURATION_SECONDS,
    COALESCE(EXECUTION_STATUS, 'UNKNOWN') AS EXECUTION_STATUS,
    
    -- Table information with validation
    COALESCE(SOURCE_TABLE_NAME, 'UNKNOWN_SOURCE') AS SOURCE_TABLE_NAME,
    COALESCE(TARGET_TABLE_NAME, 'UNKNOWN_TARGET') AS TARGET_TABLE_NAME,
    
    -- Record counts with validation
    COALESCE(RECORDS_READ, 0) AS RECORDS_READ,
    COALESCE(RECORDS_PROCESSED, 0) AS RECORDS_PROCESSED,
    COALESCE(RECORDS_INSERTED, 0) AS RECORDS_INSERTED,
    COALESCE(RECORDS_UPDATED, 0) AS RECORDS_UPDATED,
    COALESCE(RECORDS_FAILED, 0) AS RECORDS_FAILED,
    
    -- Quality metrics with validation
    CASE 
      WHEN DATA_QUALITY_SCORE BETWEEN 0 AND 100 THEN DATA_QUALITY_SCORE
      ELSE 0.0
    END AS DATA_QUALITY_SCORE,
    COALESCE(ERROR_COUNT, 0) AS ERROR_COUNT,
    COALESCE(WARNING_COUNT, 0) AS WARNING_COUNT,
    
    -- Execution context with validation
    COALESCE(PROCESS_TRIGGER, 'MANUAL') AS PROCESS_TRIGGER,
    COALESCE(EXECUTED_BY, 'UNKNOWN_USER') AS EXECUTED_BY,
    COALESCE(SERVER_NAME, 'UNKNOWN_SERVER') AS SERVER_NAME,
    COALESCE(PROCESS_VERSION, '1.0.0') AS PROCESS_VERSION,
    
    -- JSON fields with validation
    CASE 
      WHEN CONFIGURATION_PARAMETERS IS NOT NULL THEN CONFIGURATION_PARAMETERS
      ELSE PARSE_JSON('{"status": "no_configuration"}')
    END AS CONFIGURATION_PARAMETERS,
    
    CASE 
      WHEN PERFORMANCE_METRICS IS NOT NULL THEN PERFORMANCE_METRICS
      ELSE PARSE_JSON('{"status": "no_metrics"}')
    END AS PERFORMANCE_METRICS,
    
    -- Standard metadata with validation
    COALESCE(LOAD_DATE, CURRENT_DATE()) AS LOAD_DATE,
    COALESCE(UPDATE_DATE, CURRENT_DATE()) AS UPDATE_DATE,
    COALESCE(SOURCE_SYSTEM, 'UNKNOWN_SYSTEM') AS SOURCE_SYSTEM
    
  FROM audit_log_base
),

-- =====================================================
-- AUDIT LOG ENRICHMENT
-- =====================================================

audit_log_enriched AS (
  SELECT 
    *,
    
    -- Calculate derived metrics
    CASE 
      WHEN EXECUTION_STATUS = 'SUCCESS' AND ERROR_COUNT = 0 THEN 'HEALTHY'
      WHEN EXECUTION_STATUS = 'SUCCESS' AND ERROR_COUNT > 0 THEN 'WARNING'
      WHEN EXECUTION_STATUS = 'FAILED' THEN 'CRITICAL'
      ELSE 'UNKNOWN'
    END AS PROCESS_HEALTH_STATUS,
    
    -- Calculate success rate
    CASE 
      WHEN RECORDS_PROCESSED > 0 THEN 
        ROUND(((RECORDS_PROCESSED - RECORDS_FAILED) * 100.0) / RECORDS_PROCESSED, 2)
      ELSE 100.0
    END AS SUCCESS_RATE_PERCENT,
    
    -- Calculate processing rate (records per second)
    CASE 
      WHEN EXECUTION_DURATION_SECONDS > 0 THEN 
        ROUND(RECORDS_PROCESSED / EXECUTION_DURATION_SECONDS, 2)
      ELSE 0.0
    END AS PROCESSING_RATE_PER_SECOND,
    
    -- Add execution context
    CASE 
      WHEN HOUR(EXECUTION_START_TIMESTAMP) BETWEEN 6 AND 18 THEN 'BUSINESS_HOURS'
      ELSE 'OFF_HOURS'
    END AS EXECUTION_TIME_CATEGORY,
    
    -- Add data volume category
    CASE 
      WHEN RECORDS_PROCESSED >= 1000000 THEN 'LARGE_VOLUME'
      WHEN RECORDS_PROCESSED >= 100000 THEN 'MEDIUM_VOLUME'
      WHEN RECORDS_PROCESSED >= 10000 THEN 'SMALL_VOLUME'
      ELSE 'MINIMAL_VOLUME'
    END AS DATA_VOLUME_CATEGORY
    
  FROM audit_log_validated
)

-- =====================================================
-- FINAL AUDIT LOG OUTPUT
-- =====================================================

SELECT 
  -- Primary audit identifiers
  AUDIT_LOG_ID,
  PROCESS_NAME,
  PROCESS_TYPE,
  
  -- Execution timing
  EXECUTION_START_TIMESTAMP,
  EXECUTION_END_TIMESTAMP,
  EXECUTION_DURATION_SECONDS,
  EXECUTION_STATUS,
  
  -- Table information
  SOURCE_TABLE_NAME,
  TARGET_TABLE_NAME,
  
  -- Record processing metrics
  RECORDS_READ,
  RECORDS_PROCESSED,
  RECORDS_INSERTED,
  RECORDS_UPDATED,
  RECORDS_FAILED,
  
  -- Quality and error metrics
  DATA_QUALITY_SCORE,
  ERROR_COUNT,
  WARNING_COUNT,
  
  -- Execution context
  PROCESS_TRIGGER,
  EXECUTED_BY,
  SERVER_NAME,
  PROCESS_VERSION,
  
  -- Configuration and performance data
  CONFIGURATION_PARAMETERS,
  PERFORMANCE_METRICS,
  
  -- Derived metrics
  PROCESS_HEALTH_STATUS,
  SUCCESS_RATE_PERCENT,
  PROCESSING_RATE_PER_SECOND,
  EXECUTION_TIME_CATEGORY,
  DATA_VOLUME_CATEGORY,
  
  -- Standard metadata
  LOAD_DATE,
  UPDATE_DATE,
  SOURCE_SYSTEM
  
FROM audit_log_enriched

-- =====================================================
-- AUDIT LOG QUALITY CHECKS
-- =====================================================

-- Ensure we always have at least one record for initialization
WHERE 1=1

-- =====================================================
-- MODEL DOCUMENTATION
-- =====================================================

/*
MODEL DESCRIPTION:
This model creates the comprehensive audit log table for the Gold layer pipeline.
It serves as the central repository for tracking all pipeline executions, 
performance metrics, and data quality indicators.

KEY FEATURES:
1. Comprehensive execution tracking with start/end timestamps
2. Detailed record processing metrics (read, processed, inserted, updated, failed)
3. Data quality scoring and error tracking
4. Performance metrics and configuration logging
5. Derived health status and success rate calculations
6. Execution context categorization (business hours, data volume)
7. JSON-based configuration and performance metrics storage
8. Snowflake-optimized clustering for query performance

USAGE:
This table is referenced by all other Gold layer models through pre-hook and post-hook
configurations to log their execution details. It provides complete audit trail
for compliance, monitoring, and troubleshooting purposes.

DEPENDENCIES:
- None (this is the base audit table)

DOWNSTREAM USAGE:
- Referenced by all dimension and fact models for audit logging
- Used by monitoring and alerting systems
- Provides data for pipeline performance dashboards
- Supports compliance and governance reporting

DATA RETENTION:
- Recommended retention: 2 years for compliance
- Archive older records to separate table if needed
- Consider partitioning by LOAD_DATE for performance

MONITORING:
- Monitor ERROR_COUNT and WARNING_COUNT for data quality issues
- Track EXECUTION_DURATION_SECONDS for performance degradation
- Alert on EXECUTION_STATUS = 'FAILED' for immediate attention
- Monitor SUCCESS_RATE_PERCENT for overall pipeline health
*/

-- =====================================================
-- END OF AUDIT LOG MODEL
-- =====================================================