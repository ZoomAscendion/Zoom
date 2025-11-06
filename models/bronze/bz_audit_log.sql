-- =====================================================
-- Bronze Layer Audit Log Model
-- =====================================================
-- Description: Audit table for tracking all bronze layer data processing activities
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table'
) }}

-- Create audit log table structure with proper record_id generation
SELECT 
    1 AS RECORD_ID,
    CAST('SYSTEM_INIT' AS VARCHAR(255)) AS SOURCE_TABLE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CAST('DBT_INIT' AS VARCHAR(100)) AS PROCESSED_BY,
    CAST(0 AS NUMBER) AS PROCESSING_TIME,
    CAST('INITIALIZED' AS VARCHAR(50)) AS STATUS
WHERE 1=1
