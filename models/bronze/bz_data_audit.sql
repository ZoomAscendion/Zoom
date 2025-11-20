-- Bronze Layer Audit Table Model
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

-- Create audit table structure
SELECT 
    CAST(NULL AS NUMBER) AS record_id,
    CAST(NULL AS VARCHAR(255)) AS source_table,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS load_timestamp,
    CAST(NULL AS VARCHAR(255)) AS processed_by,
    CAST(NULL AS NUMBER(38,3)) AS processing_time,
    CAST(NULL AS VARCHAR(50)) AS status
WHERE 1=0  -- This ensures no data is inserted, only structure is created
