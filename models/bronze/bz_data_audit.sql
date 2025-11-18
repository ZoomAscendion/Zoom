-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT 
    CAST(1 AS NUMBER) as RECORD_ID,
    CAST('INITIALIZATION' AS VARCHAR(255)) as SOURCE_TABLE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    CAST('DBT_SYSTEM' AS VARCHAR(255)) as PROCESSED_BY,
    CAST(0.001 AS NUMBER(38,3)) as PROCESSING_TIME,
    CAST('SUCCESS' AS VARCHAR(255)) as STATUS
WHERE FALSE  -- This ensures the table is created but empty initially
