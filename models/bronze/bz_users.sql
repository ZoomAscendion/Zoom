-- Bronze Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create sample data structure for users table
SELECT 
    'USER_001' as USER_ID,
    'John Doe' as USER_NAME,
    'john.doe@gmail.com' as EMAIL,
    'Acme Corp' as COMPANY,
    'Pro' as PLAN_TYPE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    'SAMPLE_SYSTEM' as SOURCE_SYSTEM
WHERE FALSE -- This ensures the table is created but empty initially

UNION ALL

-- Add proper column structure
SELECT 
    CAST(NULL AS VARCHAR(16777216)) as USER_ID,
    CAST(NULL AS VARCHAR(16777216)) as USER_NAME,
    CAST(NULL AS VARCHAR(16777216)) as EMAIL,
    CAST(NULL AS VARCHAR(16777216)) as COMPANY,
    CAST(NULL AS VARCHAR(16777216)) as PLAN_TYPE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS UPDATE_TIMESTAMP,
    CAST(NULL AS VARCHAR(16777216)) as SOURCE_SYSTEM
WHERE FALSE
