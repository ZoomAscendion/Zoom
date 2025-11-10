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
    CAST('BZ_DATA_AUDIT' AS VARCHAR(255)) AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CAST('DBT_SYSTEM' AS VARCHAR(255)) AS processed_by,
    CAST(0.0 AS NUMBER(38,3)) AS processing_time,
    CAST('INITIALIZED' AS VARCHAR(255)) AS status
WHERE FALSE -- This creates the table structure without inserting any data
