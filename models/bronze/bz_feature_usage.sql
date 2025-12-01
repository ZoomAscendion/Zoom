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
