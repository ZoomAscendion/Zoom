/*
  Bronze Layer Audit Log Model
  Purpose: Track all data processing activities and provide audit trail
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

-- Create audit log table structure with proper data types
WITH audit_structure AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY 1) AS RECORD_ID,
        CAST('INITIAL_SETUP' AS VARCHAR(255)) AS SOURCE_TABLE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CAST('DBT_SETUP' AS VARCHAR(100)) AS PROCESSED_BY,
        CAST(0 AS NUMBER) AS PROCESSING_TIME,
        CAST('COMPLETED' AS VARCHAR(50)) AS STATUS
    WHERE 1=0  -- This ensures no data is selected, only structure is created
)

SELECT * FROM audit_structure
