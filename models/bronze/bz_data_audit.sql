-- Bronze Layer Audit Table Model
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create audit table with auto-increment record_id
SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS record_id,
    'INITIAL_SETUP' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_BRONZE_PIPELINE' AS processed_by,
    0.0 AS processing_time,
    'SUCCESS' AS status
WHERE FALSE  -- This ensures no data is inserted initially, just creates the structure
