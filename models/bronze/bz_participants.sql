-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='participant_id'
) }}

-- Create sample participants data
WITH sample_participants AS (
    SELECT 
        'PART001' as participant_id,
        'MEET001' as meeting_id,
        'USER001' as user_id,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as join_time,
        CURRENT_TIMESTAMP() as leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
    
    UNION ALL
    
    SELECT 
        'PART002' as participant_id,
        'MEET001' as meeting_id,
        'USER002' as user_id,
        CURRENT_TIMESTAMP() - INTERVAL '55 minutes' as join_time,
        CURRENT_TIMESTAMP() as leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
        
    UNION ALL
    
    SELECT 
        'PART003' as participant_id,
        'MEET002' as meeting_id,
        'USER003' as user_id,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as join_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
)

SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    load_timestamp,
    update_timestamp,
    source_system
FROM sample_participants
