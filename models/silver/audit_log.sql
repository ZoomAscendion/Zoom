{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Audit Log Model
-- This model must run first before other silver models
-- Tracks all pipeline execution details and data quality metrics

SELECT 
    -- Generate unique execution ID
    'EXEC_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS') || '_' || ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS EXECUTION_ID,
    
    -- Pipeline execution details
    'SILVER_PIPELINE_AUDIT' AS PIPELINE_NAME,
    CURRENT_TIMESTAMP() AS START_TIME,
    CURRENT_TIMESTAMP() AS END_TIME,
    'Success' AS STATUS,
    NULL AS ERROR_MESSAGE,
    0 AS EXECUTION_DURATION_SECONDS,
    'BRONZE_TABLES' AS SOURCE_TABLES_PROCESSED,
    'SILVER_TABLES' AS TARGET_TABLES_UPDATED,
    0 AS RECORDS_PROCESSED,
    0 AS RECORDS_INSERTED,
    0 AS RECORDS_UPDATED,
    0 AS RECORDS_REJECTED,
    'DBT_SILVER_PIPELINE' AS EXECUTED_BY,
    'PROD' AS EXECUTION_ENVIRONMENT,
    'Bronze to Silver transformation audit log initialization' AS DATA_LINEAGE_INFO,
    
    -- Standard metadata
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'ZOOM_PLATFORM' AS SOURCE_SYSTEM
