/*
  Bronze Layer Audit Log Model
  
  Purpose: Creates audit log table for tracking data processing activities
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
  
  Description:
  - Creates the audit log table first to support other models
  - Tracks processing start/end times and status
  - Provides data lineage and monitoring capabilities
*/

{{ config(
    materialized='table'
) }}

-- Create audit log table structure with proper data types
SELECT 
    1 AS record_id,
    'INITIAL' AS source_table,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'DBT_PROCESS' AS processed_by,
    0 AS processing_time,
    'COMPLETED' AS status
WHERE 1=0  -- Create empty table with proper structure
