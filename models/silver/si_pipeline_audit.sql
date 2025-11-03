{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Pipeline Audit Model
-- Description: Comprehensive audit table for tracking all Silver layer pipeline execution details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

WITH audit_source AS (
    SELECT 
        -- Generate unique execution ID
        'EXEC_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS') || '_' || ROW_NUMBER() OVER (ORDER BY LOAD_TIMESTAMP) AS EXECUTION_ID,
        
        -- Pipeline execution details
        'SILVER_' || UPPER(SOURCE_TABLE) AS PIPELINE_NAME,
        LOAD_TIMESTAMP AS START_TIME,
        CREATED_TIMESTAMP AS END_TIME,
        
        -- Status mapping
        CASE 
            WHEN UPPER(STATUS) = 'SUCCESS' THEN 'Success'
            WHEN UPPER(STATUS) = 'FAILED' THEN 'Failed'
            WHEN UPPER(STATUS) = 'PARTIAL' THEN 'Partial Success'
            ELSE 'Cancelled'
        END AS STATUS,
        
        ERROR_MESSAGE,
        COALESCE(PROCESSING_TIME, 0) AS EXECUTION_DURATION_SECONDS,
        SOURCE_TABLE AS SOURCE_TABLES_PROCESSED,
        'SI_' || UPPER(SOURCE_TABLE) AS TARGET_TABLES_UPDATED,
        COALESCE(RECORD_COUNT, 0) AS RECORDS_PROCESSED,
        
        -- Calculate records inserted/updated based on status
        CASE 
            WHEN UPPER(STATUS) = 'SUCCESS' THEN COALESCE(RECORD_COUNT, 0)
            ELSE 0
        END AS RECORDS_INSERTED,
        
        CASE 
            WHEN UPPER(STATUS) = 'PARTIAL' THEN COALESCE(RECORD_COUNT, 0) / 2
            ELSE 0
        END AS RECORDS_UPDATED,
        
        -- Calculate rejected records
        CASE 
            WHEN UPPER(STATUS) = 'FAILED' THEN COALESCE(RECORD_COUNT, 0)
            WHEN ERROR_MESSAGE IS NOT NULL THEN 1
            ELSE 0
        END AS RECORDS_REJECTED,
        
        COALESCE(PROCESSED_BY, 'SYSTEM') AS EXECUTED_BY,
        'PROD' AS EXECUTION_ENVIRONMENT,
        'Bronze -> Silver transformation for ' || SOURCE_TABLE AS DATA_LINEAGE_INFO,
        
        -- Standard metadata columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(CREATED_TIMESTAMP) AS UPDATE_DATE,
        COALESCE(SOURCE_TABLE, 'UNKNOWN') AS SOURCE_SYSTEM
        
    FROM {{ ref('bz_audit_records') }}
    WHERE SOURCE_TABLE IS NOT NULL
),

final_audit AS (
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
        SOURCE_SYSTEM,
        
        -- Add audit columns
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT,
        'SUCCESS' AS PROCESS_STATUS
        
    FROM audit_source
)

SELECT * FROM final_audit
