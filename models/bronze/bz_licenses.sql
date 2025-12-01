-- Bronze Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create sample data structure for licenses table
SELECT 
    'LICENSE_001' as LICENSE_ID,
    'Pro' as LICENSE_TYPE,
    'USER_001' as ASSIGNED_TO_USER_ID,
    CURRENT_DATE() as START_DATE,
    DATEADD('year', 1, CURRENT_DATE()) as END_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    'SAMPLE_SYSTEM' as SOURCE_SYSTEM
WHERE FALSE -- This ensures the table is created but empty initially

UNION ALL

-- Add proper column structure
SELECT 
    CAST(NULL AS VARCHAR(16777216)) as LICENSE_ID,
    CAST(NULL AS VARCHAR(16777216)) as LICENSE_TYPE,
    CAST(NULL AS VARCHAR(16777216)) as ASSIGNED_TO_USER_ID,
    CAST(NULL AS DATE) as START_DATE,
    CAST(NULL AS DATE) as END_DATE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS UPDATE_TIMESTAMP,
    CAST(NULL AS VARCHAR(16777216)) as SOURCE_SYSTEM
WHERE FALSE
