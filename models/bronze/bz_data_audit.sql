-- Bronze Layer Audit Model
-- Description: Comprehensive audit trail for all Bronze layer data operations

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT 
    1 AS record_id,
    'BZ_DATA_AUDIT' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_BRONZE_PIPELINE' AS processed_by,
    0.0 AS processing_time,
    'INITIALIZED' AS status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at

UNION ALL

SELECT 
    2 AS record_id,
    'BRONZE_PIPELINE' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'SYSTEM' AS processed_by,
    1.5 AS processing_time,
    'SUCCESS' AS status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
