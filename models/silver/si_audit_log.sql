{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- SI_AUDIT_LOG: Audit table for Silver layer pipeline execution tracking
-- This table must be created first before other models run

SELECT 
    CAST(NULL AS VARCHAR(255)) AS TABLE_NAME,
    CAST(NULL AS VARCHAR(255)) AS COLUMN_NAME,
    CAST(NULL AS VARCHAR(100)) AS ERROR_TYPE,
    CAST(NULL AS VARCHAR(500)) AS ERROR_DESCRIPTION,
    CAST(NULL AS VARCHAR(255)) AS RECORD_ID,
    CAST(NULL AS VARCHAR(500)) AS ORIGINAL_VALUE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS AUDIT_TIMESTAMP,
    CAST(NULL AS VARCHAR(50)) AS STATUS,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP
WHERE FALSE
