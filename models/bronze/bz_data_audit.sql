-- Bronze Layer Audit Table
-- Description: Comprehensive audit trail for all Bronze layer data operations
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create audit table structure with proper column definitions
WITH audit_structure AS (
    SELECT 
        CAST(NULL AS NUMBER) as RECORD_ID,
        CAST(NULL AS VARCHAR(255)) as SOURCE_TABLE,
        CAST(NULL AS TIMESTAMP_NTZ) as LOAD_TIMESTAMP,
        CAST(NULL AS VARCHAR(255)) as PROCESSED_BY,
        CAST(NULL AS NUMBER(38,3)) as PROCESSING_TIME,
        CAST(NULL AS VARCHAR(255)) as STATUS
    WHERE FALSE -- This ensures no actual data is inserted during initial creation
)

SELECT * FROM audit_structure
