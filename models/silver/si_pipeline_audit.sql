{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Pipeline Audit Table
-- This table tracks all Silver layer pipeline execution details
-- Must be created first to support audit logging in other models

WITH audit_base AS (
    SELECT 
        -- Generate unique execution ID
        CONCAT('EXEC_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING, '_', ROW_NUMBER() OVER (ORDER BY LOAD_TIMESTAMP)) AS EXECUTION_ID,
        
        -- Pipeline execution details
        CONCAT('SILVER_', SOURCE_TABLE) AS PIPELINE_NAME,
        LOAD_TIMESTAMP AS START_TIME,
        CREATED_TIMESTAMP AS END_TIME,
        CASE 
            WHEN STATUS = 'SUCCESS' THEN 'Success'
            WHEN STATUS = 'FAILED' THEN 'Failed'
            WHEN STATUS = 'PARTIAL' THEN 'Partial Success'
            ELSE 'Cancelled'
        END AS STATUS,
        
        ERROR_MESSAGE,
        PROCESSING_TIME AS EXECUTION_DURATION_SECONDS,
        SOURCE_TABLE AS SOURCE_TABLES_PROCESSED,
        CONCAT('SI_', REPLACE(SOURCE_TABLE, 'BZ_', '')) AS TARGET_TABLES_UPDATED,
        RECORD_COUNT AS RECORDS_PROCESSED,
        
        -- Derive records inserted/updated based on status
        CASE WHEN STATUS = 'SUCCESS' THEN RECORD_COUNT ELSE 0 END AS RECORDS_INSERTED,
        CASE WHEN STATUS = 'SUCCESS' THEN 0 ELSE RECORD_COUNT END AS RECORDS_UPDATED,
        CASE WHEN STATUS = 'FAILED' THEN RECORD_COUNT ELSE 0 END AS RECORDS_REJECTED,
        
        PROCESSED_BY AS EXECUTED_BY,
        'PROD' AS EXECUTION_ENVIRONMENT,
        CONCAT('Bronze -> Silver transformation for ', SOURCE_TABLE) AS DATA_LINEAGE_INFO,
        
        -- Standard metadata columns
        LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        CREATED_TIMESTAMP::DATE AS UPDATE_DATE,
        CONCAT('BRONZE_', SOURCE_TABLE) AS SOURCE_SYSTEM
        
    FROM {{ source('bronze', 'bz_audit_records') }}
    WHERE SOURCE_TABLE IS NOT NULL
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
