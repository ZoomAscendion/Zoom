-- Bronze Layer Audit Table Model
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT 
    RECORD_ID,
    SOURCE_TABLE,
    LOAD_TIMESTAMP,
    PROCESSED_BY,
    PROCESSING_TIME,
    STATUS
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) as RECORD_ID,
        'AUDIT_INITIALIZATION' as SOURCE_TABLE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        'DBT_SYSTEM' as PROCESSED_BY,
        0.0 as PROCESSING_TIME,
        'SUCCESS' as STATUS
    WHERE FALSE -- This ensures no records are inserted during model creation
)
