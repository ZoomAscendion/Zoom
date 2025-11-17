-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook=None,
    post_hook=None
) }}

SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS RECORD_ID,
    'BZ_DATA_AUDIT' AS SOURCE_TABLE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    'DBT_BRONZE_PIPELINE' AS PROCESSED_BY,
    0.001 AS PROCESSING_TIME,
    'INITIALIZED' AS STATUS
WHERE FALSE -- This creates the table structure without inserting any rows initially
