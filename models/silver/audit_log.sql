{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Audit Log Model
-- This model must run first before other silver models
-- Tracks all pipeline execution details and data quality metrics

WITH audit_base AS (
    SELECT 
        -- Generate unique execution ID
        'EXEC_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS') || '_' || ROW_NUMBER() OVER (ORDER BY LOAD_TIMESTAMP) AS EXECUTION_ID,
        
        -- Pipeline execution details
        'SILVER_PIPELINE_' || SOURCE_TABLE AS PIPELINE_NAME,
        LOAD_TIMESTAMP AS START_TIME,
        CURRENT_TIMESTAMP() AS END_TIME,
        
        -- Status mapping
        CASE 
            WHEN STATUS = 'SUCCESS' THEN 'Success'
            WHEN STATUS = 'FAILED' THEN 'Failed'
            WHEN STATUS = 'PARTIAL' THEN 'Partial Success'
            ELSE 'Unknown'
        END AS STATUS,
        
        ERROR_MESSAGE,
        PROCESSING_TIME AS EXECUTION_DURATION_SECONDS,
        SOURCE_TABLE AS SOURCE_TABLES_PROCESSED,
        'SI_' || REPLACE(SOURCE_TABLE, 'BZ_', '') AS TARGET_TABLES_UPDATED,
        RECORD_COUNT AS RECORDS_PROCESSED,
        
        -- Derive record counts based on status
        CASE WHEN STATUS = 'SUCCESS' THEN RECORD_COUNT ELSE 0 END AS RECORDS_INSERTED,
        CASE WHEN STATUS = 'PARTIAL' THEN RECORD_COUNT ELSE 0 END AS RECORDS_UPDATED,
        CASE WHEN STATUS = 'FAILED' THEN RECORD_COUNT ELSE 0 END AS RECORDS_REJECTED,
        
        PROCESSED_BY AS EXECUTED_BY,
        'PROD' AS EXECUTION_ENVIRONMENT,
        'Bronze -> Silver transformation for ' || SOURCE_TABLE AS DATA_LINEAGE_INFO,
        
        -- Standard metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
        'ZOOM_PLATFORM' AS SOURCE_SYSTEM
        
    FROM {{ ref('bronze_audit_records') }}
    WHERE LOAD_TIMESTAMP >= DATEADD('day', -7, CURRENT_TIMESTAMP())
)

SELECT 
    EXECUTION_ID,
    PIPELINE_NAME,
    START_TIME,
    END_TIME,
    STATUS,
    ERROR_MESSAGE,
    EXECUTION_DURATION_SECONDS,
    SOURCE_TABLES_PROCESSED,
    TARGET_TABLES_UPDATED,
    RECORDS_PROCESSED,
    RECORDS_INSERTED,
    RECORDS_UPDATED,
    RECORDS_REJECTED,
    EXECUTED_BY,
    EXECUTION_ENVIRONMENT,
    DATA_LINEAGE_INFO,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM audit_base
