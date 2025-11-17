-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='record_id'
) }}

SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS record_id,
    'BZ_DATA_AUDIT' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_BRONZE_PIPELINE' AS processed_by,
    0.001 AS processing_time,
    'INITIALIZED' AS status
WHERE FALSE  -- This ensures no actual data is inserted during initial creation
