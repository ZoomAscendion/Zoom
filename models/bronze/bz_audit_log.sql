/*
  Bronze Audit Log Model
  Purpose: Track data processing activities and provide audit trail
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook=None,
    post_hook=None
) }}

WITH audit_base AS (
    SELECT
        -- Audit tracking fields
        ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS record_id,
        'AUDIT_LOG' AS source_table,
        CURRENT_TIMESTAMP() AS load_timestamp,
        'DBT_SYSTEM' AS processed_by,
        0 AS processing_time,
        'INITIALIZED' AS status
    FROM (SELECT 1) -- Dummy row to initialize the audit log
)

SELECT
    record_id::NUMBER AS record_id,
    source_table::VARCHAR(255) AS source_table,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    processed_by::VARCHAR(100) AS processed_by,
    processing_time::NUMBER AS processing_time,
    status::VARCHAR(50) AS status
FROM audit_base
WHERE FALSE -- This ensures no actual data is inserted during model creation
