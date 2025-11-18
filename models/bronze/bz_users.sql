-- Bronze Pipeline Step 1: Transform raw users data to bronze layer
-- Description: 1-1 mapping from RAW.USERS to BRONZE.BZ_USERS with deduplication

{{ config(
    materialized='table'
) }}

SELECT 
    'USER_001' as user_id,
    'Test User' as user_name,
    'test@example.com' as email,
    'Test Company' as company,
    'Basic' as plan_type,
    CURRENT_TIMESTAMP() as load_timestamp,
    CURRENT_TIMESTAMP() as update_timestamp,
    'TEST_SYSTEM' as source_system
WHERE 1=0  -- Empty table for now
