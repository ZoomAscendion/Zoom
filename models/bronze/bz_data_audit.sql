/*
  Author: Data Engineering Team
  Created: 2024-12-19
  Description: Audit table for tracking all Bronze layer data operations
  Purpose: Provides comprehensive audit trail for data lineage and monitoring
*/

{{ config(
    materialized='table',
    tags=['bronze', 'audit']
) }}

SELECT
    -- Auto-incrementing unique identifier for each audit record
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS RECORD_ID,
    
    -- Name of the Bronze layer table being audited
    CAST(NULL AS VARCHAR(255)) AS SOURCE_TABLE,
    
    -- Timestamp when the operation occurred
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    
    -- User or process that performed the operation
    CAST(NULL AS VARCHAR(255)) AS PROCESSED_BY,
    
    -- Time taken to process the operation in seconds
    CAST(NULL AS NUMBER(38,3)) AS PROCESSING_TIME,
    
    -- Status of the operation (SUCCESS, FAILED, WARNING)
    CAST(NULL AS VARCHAR(255)) AS STATUS

WHERE 1 = 0  -- Creates empty table with proper schema
