-- =====================================================
-- BRONZE LAYER AUDIT TABLE
-- Purpose: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table'
) }}

-- Create audit table with proper structure
SELECT 
    1 AS RECORD_ID,
    'SYSTEM_INIT' AS SOURCE_TABLE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    'DBT_SYSTEM' AS PROCESSED_BY,
    0.001 AS PROCESSING_TIME,
    'INITIALIZED' AS STATUS
WHERE 1=0  -- This ensures no actual data is inserted initially
