{{
    config(
        materialized='table',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Pipeline Audit Table
-- This table tracks all pipeline executions and must be created first

WITH audit_base AS (
    SELECT
        'AUDIT_' || REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', '') AS EXECUTION_ID,
        'SI_PIPELINE_AUDIT_INIT' AS PIPELINE_NAME,
        CURRENT_TIMESTAMP() AS START_TIME,
        CURRENT_TIMESTAMP() AS END_TIME,
        'SUCCESS' AS STATUS,
        NULL AS ERROR_MESSAGE,
        0 AS EXECUTION_DURATION_SECONDS,
        'SI_PIPELINE_AUDIT' AS SOURCE_TABLES_PROCESSED,
        'SI_PIPELINE_AUDIT' AS TARGET_TABLES_UPDATED,
        0 AS RECORDS_PROCESSED,
        0 AS RECORDS_INSERTED,
        0 AS RECORDS_UPDATED,
        0 AS RECORDS_REJECTED,
        'DBT_SILVER_PIPELINE' AS EXECUTED_BY,
        'PRODUCTION' AS EXECUTION_ENVIRONMENT,
        'Initial audit table creation' AS DATA_LINEAGE_INFO,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'ZOOM_PLATFORM' AS SOURCE_SYSTEM
)

SELECT * FROM audit_base
