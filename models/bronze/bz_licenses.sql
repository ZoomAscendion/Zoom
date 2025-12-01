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
