-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='meeting_id'
) }}

-- Create sample meetings data
WITH sample_meetings AS (
    SELECT 
        'MEET001' as meeting_id,
        'USER001' as host_id,
        'Weekly Team Standup' as meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as start_time,
        CURRENT_TIMESTAMP() as end_time,
        60 as duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
    
    UNION ALL
    
    SELECT 
        'MEET002' as meeting_id,
        'USER002' as host_id,
        'Client Presentation' as meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as start_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as end_time,
        60 as duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
        
    UNION ALL
    
    SELECT 
        'MEET003' as meeting_id,
        'USER003' as host_id,
        'Product Demo' as meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '3 hours' as start_time,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as end_time,
        60 as duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
)

SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    load_timestamp,
    update_timestamp,
    source_system
FROM sample_meetings
