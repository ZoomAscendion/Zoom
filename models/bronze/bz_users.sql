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
