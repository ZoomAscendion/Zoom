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
    materialized='table',
    pre_hook=none,
    post_hook=none
) }}

-- Create audit log table structure
SELECT 
    CAST(NULL AS NUMBER) AS record_id,
    CAST(NULL AS VARCHAR(255)) AS source_table,
    CAST(NULL AS TIMESTAMP_NTZ) AS load_timestamp,
    CAST(NULL AS VARCHAR(100)) AS processed_by,
    CAST(NULL AS NUMBER) AS processing_time,
    CAST(NULL AS VARCHAR(50)) AS status
WHERE 1=0  -- Create empty table with proper structure
