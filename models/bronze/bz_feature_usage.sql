-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='usage_id'
) }}

-- Create sample feature usage data
WITH sample_feature_usage AS (
    SELECT 
        'USAGE001' as usage_id,
        'MEET001' as meeting_id,
        'screen_share' as feature_name,
        5 as usage_count,
        CURRENT_DATE() as usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
    
    UNION ALL
    
    SELECT 
        'USAGE002' as usage_id,
        'MEET001' as meeting_id,
        'chat' as feature_name,
        15 as usage_count,
        CURRENT_DATE() as usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
        
    UNION ALL
    
    SELECT 
        'USAGE003' as usage_id,
        'MEET002' as meeting_id,
        'recording' as feature_name,
        1 as usage_count,
        CURRENT_DATE() as usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
)

SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM sample_feature_usage
