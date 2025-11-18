-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

WITH audit_base AS (
    SELECT 
        'BZ_DATA_AUDIT' AS source_table,
        CURRENT_TIMESTAMP() AS load_timestamp,
        'DBT_BRONZE_PIPELINE' AS processed_by,
        0.0 AS processing_time,
        'INITIALIZED' AS status
    WHERE FALSE -- This ensures no actual data is inserted during model creation
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY load_timestamp) AS record_id,
    CAST(source_table AS VARCHAR(255)) AS source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_base
