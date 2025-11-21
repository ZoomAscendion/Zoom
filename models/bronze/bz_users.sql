-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='user_id'
) }}

-- Create sample users data since raw tables don't exist
WITH sample_users AS (
    SELECT 
        'USER001' as user_id,
        'John Doe' as user_name,
        'john.doe@example.com' as email,
        'Acme Corp' as company,
        'Pro' as plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
    
    UNION ALL
    
    SELECT 
        'USER002' as user_id,
        'Jane Smith' as user_name,
        'jane.smith@company.com' as email,
        'Tech Solutions' as company,
        'Enterprise' as plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
        
    UNION ALL
    
    SELECT 
        'USER003' as user_id,
        'Bob Johnson' as user_name,
        'bob.johnson@startup.com' as email,
        'Startup Inc' as company,
        'Basic' as plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
)

SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    load_timestamp,
    update_timestamp,
    source_system
FROM sample_users
