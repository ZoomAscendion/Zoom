-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS RECORD_ID,
    'BZ_DATA_AUDIT' AS SOURCE_TABLE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    '{{ var("audit_user") }}' AS PROCESSED_BY,
    0.0 AS PROCESSING_TIME,
    'INITIALIZED' AS STATUS
WHERE FALSE -- This creates the table structure without inserting any rows initially
