-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id'
) }}

-- Create sample licenses data
WITH sample_licenses AS (
    SELECT 
        'LIC001' as license_id,
        'Pro' as license_type,
        'USER001' as assigned_to_user_id,
        CURRENT_DATE() - 30 as start_date,
        CURRENT_DATE() + 335 as end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
    
    UNION ALL
    
    SELECT 
        'LIC002' as license_id,
        'Enterprise' as license_type,
        'USER002' as assigned_to_user_id,
        CURRENT_DATE() - 60 as start_date,
        CURRENT_DATE() + 305 as end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
        
    UNION ALL
    
    SELECT 
        'LIC003' as license_id,
        'Basic' as license_type,
        'USER003' as assigned_to_user_id,
        CURRENT_DATE() - 10 as start_date,
        CURRENT_DATE() + 355 as end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
)

SELECT 
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM sample_licenses
