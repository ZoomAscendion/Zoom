-- Bronze Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create sample data structure for support tickets table
SELECT 
    'TICKET_001' as TICKET_ID,
    'USER_001' as USER_ID,
    'Technical' as TICKET_TYPE,
    'Open' as RESOLUTION_STATUS,
    CURRENT_DATE() as OPEN_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    'SAMPLE_SYSTEM' as SOURCE_SYSTEM
WHERE FALSE -- This ensures the table is created but empty initially

UNION ALL

-- Add proper column structure
SELECT 
    CAST(NULL AS VARCHAR(16777216)) as TICKET_ID,
    CAST(NULL AS VARCHAR(16777216)) as USER_ID,
    CAST(NULL AS VARCHAR(16777216)) as TICKET_TYPE,
    CAST(NULL AS VARCHAR(16777216)) as RESOLUTION_STATUS,
    CAST(NULL AS DATE) as OPEN_DATE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS UPDATE_TIMESTAMP,
    CAST(NULL AS VARCHAR(16777216)) as SOURCE_SYSTEM
WHERE FALSE
