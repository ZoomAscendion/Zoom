{{ config(
    materialized='table',
    unique_key='record_id'
) }}

WITH audit_base AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS record_id,
        CAST(NULL AS VARCHAR(255)) AS source_table,
        CAST(NULL AS TIMESTAMP_NTZ) AS process_start_time,
        CAST(NULL AS TIMESTAMP_NTZ) AS process_end_time,
        CAST(NULL AS VARCHAR(50)) AS process_status,
        CAST(NULL AS VARCHAR(1000)) AS error_message,
        CAST(NULL AS NUMBER) AS records_processed,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
    WHERE 1=0  -- This ensures no records are inserted during initial creation
)

SELECT * FROM audit_base
