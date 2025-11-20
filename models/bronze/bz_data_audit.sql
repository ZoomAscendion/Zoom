-- Bronze Layer Audit Table Model
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

-- Create audit table structure with explicit column definitions
SELECT
    CAST(1 AS NUMBER) AS record_id,
    CAST('INITIAL' AS VARCHAR(255)) AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CAST('DBT_SYSTEM' AS VARCHAR(255)) AS processed_by,
    CAST(0.0 AS NUMBER(38,3)) AS processing_time,
    CAST('INITIALIZED' AS VARCHAR(50)) AS status
WHERE 1=0  -- This ensures no data is inserted, only structure is created
