-- Bronze Meetings Table
-- Description: Stores meeting information and session details
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create sample data structure for meetings table
SELECT 
    'MEETING_001' as MEETING_ID,
    'USER_001' as HOST_ID,
    'Sample Meeting' as MEETING_TOPIC,
    CURRENT_TIMESTAMP() as START_TIME,
    CURRENT_TIMESTAMP() as END_TIME,
    60 as DURATION_MINUTES,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    'SAMPLE_SYSTEM' as SOURCE_SYSTEM
WHERE FALSE -- This ensures the table is created but empty initially

UNION ALL

-- Add proper column structure
SELECT 
    CAST(NULL AS VARCHAR(16777216)) as MEETING_ID,
    CAST(NULL AS VARCHAR(16777216)) as HOST_ID,
    CAST(NULL AS VARCHAR(16777216)) as MEETING_TOPIC,
    CAST(NULL AS TIMESTAMP_NTZ(9)) as START_TIME,
    CAST(NULL AS TIMESTAMP_NTZ(9)) as END_TIME,
    CAST(NULL AS NUMBER(38,0)) as DURATION_MINUTES,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS UPDATE_TIMESTAMP,
    CAST(NULL AS VARCHAR(16777216)) as SOURCE_SYSTEM
WHERE FALSE
