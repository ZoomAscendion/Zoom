{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Pipeline Audit Table
-- Independent audit tracking for Silver layer transformations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

SELECT
    -- Generate unique execution ID for this Silver pipeline run
    CONCAT('SILVER_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING, '_', RANDOM()::STRING) AS EXECUTION_ID,
    
    -- Pipeline identification
    'SILVER_PIPELINE_INITIALIZATION' AS PIPELINE_NAME,
    CURRENT_TIMESTAMP() AS START_TIME,
    CURRENT_TIMESTAMP() AS END_TIME,
    'Success' AS STATUS,
    NULL AS ERROR_MESSAGE,
    0 AS EXECUTION_DURATION_SECONDS,
    
    -- Processing details
    'BRONZE_TABLES' AS SOURCE_TABLES_PROCESSED,
    'SI_PIPELINE_AUDIT' AS TARGET_TABLES_UPDATED,
    1 AS RECORDS_PROCESSED,
    1 AS RECORDS_INSERTED,
    0 AS RECORDS_UPDATED,
    0 AS RECORDS_REJECTED,
    
    -- Execution context
    'DBT_SILVER_PIPELINE' AS EXECUTED_BY,
    'PRODUCTION' AS EXECUTION_ENVIRONMENT,
    'Silver layer audit table initialization' AS DATA_LINEAGE_INFO,
    
    -- Standard metadata
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SILVER_LAYER' AS SOURCE_SYSTEM
