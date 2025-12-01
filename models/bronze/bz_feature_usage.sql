-- Bronze Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create sample data structure for feature usage table
SELECT 
    'USAGE_001' as USAGE_ID,
    'MEETING_001' as MEETING_ID,
    'Screen Share' as FEATURE_NAME,
    5 as USAGE_COUNT,
    CURRENT_DATE() as USAGE_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    'SAMPLE_SYSTEM' as SOURCE_SYSTEM
WHERE FALSE -- This ensures the table is created but empty initially

UNION ALL

-- Add proper column structure
SELECT 
    CAST(NULL AS VARCHAR(16777216)) as USAGE_ID,
    CAST(NULL AS VARCHAR(16777216)) as MEETING_ID,
    CAST(NULL AS VARCHAR(16777216)) as FEATURE_NAME,
    CAST(NULL AS NUMBER(38,0)) as USAGE_COUNT,
    CAST(NULL AS DATE) as USAGE_DATE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS UPDATE_TIMESTAMP,
    CAST(NULL AS VARCHAR(16777216)) as SOURCE_SYSTEM
WHERE FALSE
