/*
  Bronze Layer Audit Log Model
  Purpose: Track all data processing activities in the bronze layer
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook=none,
    post_hook=none
) }}

WITH audit_base AS (
    SELECT
        -- Audit tracking columns
        NULL::NUMBER AS record_id,
        'INITIAL_SETUP'::VARCHAR(255) AS source_table,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS load_timestamp,
        'DBT'::VARCHAR(100) AS processed_by,
        0::NUMBER AS processing_time,
        'COMPLETED'::VARCHAR(50) AS status
    WHERE FALSE -- This ensures no initial records are created
)

SELECT 
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status
FROM audit_base
