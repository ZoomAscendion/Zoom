{{ config(
    materialized='table'
) }}

-- Audit log table for tracking all Gold layer transformations
-- This table must be created first and runs before any other models

SELECT 
    UUID_STRING() AS AUDIT_ID,
    'GOLD_LAYER_INIT' AS PIPELINE_NAME,
    'N/A' AS SOURCE_TABLE,
    'GO_AUDIT_LOG' AS TARGET_TABLE,
    CURRENT_TIMESTAMP() AS EXECUTION_START_TIME,
    CURRENT_TIMESTAMP() AS EXECUTION_END_TIME,
    'SUCCESS' AS EXECUTION_STATUS,
    0 AS RECORDS_PROCESSED,
    'Audit log initialized' AS ERROR_MESSAGE,
    CURRENT_TIMESTAMP() AS CREATED_AT,
    CURRENT_TIMESTAMP() AS UPDATED_AT
