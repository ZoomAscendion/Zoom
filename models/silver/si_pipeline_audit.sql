{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Pipeline Audit Log Table
-- This table tracks all Silver layer pipeline execution details independently

WITH audit_base AS (
    SELECT
        'AUDIT_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_') AS EXECUTION_ID,
        'Silver_Pipeline_Initialization' AS PIPELINE_NAME,
        CURRENT_TIMESTAMP() AS START_TIME,
        CURRENT_TIMESTAMP() AS END_TIME,
        'SUCCESS' AS STATUS,
        NULL AS ERROR_MESSAGE,
        0 AS EXECUTION_DURATION_SECONDS,
        'BRONZE_TABLES' AS SOURCE_TABLES_PROCESSED,
        'SI_PIPELINE_AUDIT' AS TARGET_TABLES_UPDATED,
        1 AS RECORDS_PROCESSED,
        1 AS RECORDS_INSERTED,
        0 AS RECORDS_UPDATED,
        0 AS RECORDS_REJECTED,
        'DBT_SILVER_JOB' AS EXECUTED_BY,
        'PRODUCTION' AS EXECUTION_ENVIRONMENT,
        'Silver audit table initialization' AS DATA_LINEAGE_INFO,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'ZOOM_PLATFORM' AS SOURCE_SYSTEM
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
 CAST('INIT_001' AS VARCHAR(255)) as execution_id,
    CAST('pipeline_initialization' AS VARCHAR(255)) as pipeline_name,
    CURRENT_TIMESTAMP() as start_time,
    CURRENT_TIMESTAMP() as end_time,
    CAST('SUCCESS' AS VARCHAR(255)) as status,
    CAST(NULL AS VARCHAR(16777216)) as error_message,
    0 as execution_duration_seconds,
    CAST('INITIALIZATION' AS VARCHAR(255)) as source_tables_processed,
    CAST('SI_PIPELINE_AUDIT' AS VARCHAR(255)) as target_tables_updated,
    1 as records_processed,
    1 as records_inserted,
    0 as records_updated,
    0 as records_rejected,
    CURRENT_USER() as executed_by,
    CAST('PROD' AS VARCHAR(255)) as execution_environment,
    CAST('Initial audit table creation' AS VARCHAR(16777216)) as data_lineage_info,
    CURRENT_DATE() as load_date,
    CURRENT_DATE() as update_date,
    CAST('DBT_SILVER_PIPELINE' AS VARCHAR(255)) as source_system
