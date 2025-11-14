-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

-- Create audit table structure with proper RECORD_ID handling
WITH audit_base AS (
    SELECT 
        1 AS RECORD_ID,
        'INITIAL_SETUP' AS SOURCE_TABLE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        'DBT_BRONZE_SETUP' AS PROCESSED_BY,
        0.0 AS PROCESSING_TIME,
        'SUCCESS' AS STATUS
    WHERE 1=0  -- This ensures no data is inserted during initial setup
)

SELECT 
    CAST(RECORD_ID AS NUMBER) AS RECORD_ID,
    CAST(SOURCE_TABLE AS VARCHAR(255)) AS SOURCE_TABLE,
    CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(PROCESSED_BY AS VARCHAR(255)) AS PROCESSED_BY,
    CAST(PROCESSING_TIME AS NUMBER(38,3)) AS PROCESSING_TIME,
    CAST(STATUS AS VARCHAR(255)) AS STATUS
FROM audit_base
