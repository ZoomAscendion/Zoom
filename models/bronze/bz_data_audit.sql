-- =====================================================
-- BRONZE LAYER AUDIT TABLE
-- Purpose: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table',
    pre_hook=None,
    post_hook=None
) }}

-- Create audit table with proper structure and initial data
WITH audit_structure AS (
    SELECT 
        1 AS RECORD_ID,
        'SYSTEM_INIT' AS SOURCE_TABLE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        'DBT_SYSTEM' AS PROCESSED_BY,
        0.001 AS PROCESSING_TIME,
        'INITIALIZED' AS STATUS
    WHERE 1=0  -- This ensures no actual data is inserted initially
)

SELECT 
    CAST(RECORD_ID AS NUMBER) AS RECORD_ID,
    CAST(SOURCE_TABLE AS VARCHAR(255)) AS SOURCE_TABLE,
    CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(PROCESSED_BY AS VARCHAR(255)) AS PROCESSED_BY,
    CAST(PROCESSING_TIME AS NUMBER(38,3)) AS PROCESSING_TIME,
    CAST(STATUS AS VARCHAR(50)) AS STATUS
FROM audit_structure
