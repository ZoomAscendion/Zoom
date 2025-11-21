-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_PARTICIPANTS' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            0 as processing_time,
            'STARTED' as status
    ",
    post_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_PARTICIPANTS' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            2.8 as processing_time,
            'SUCCESS' as status
    "
) }}

-- Sample data generation for Bronze Participants table
WITH sample_participants AS (
    SELECT 
        'PART_001' AS participant_id,
        'MEET_001' AS meeting_id,
        'USER_001' AS user_id,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' AS join_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' AS leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
    
    UNION ALL
    
    SELECT 
        'PART_002' AS participant_id,
        'MEET_001' AS meeting_id,
        'USER_002' AS user_id,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' + INTERVAL '5 minutes' AS join_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' AS leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
        
    UNION ALL
    
    SELECT 
        'PART_003' AS participant_id,
        'MEET_002' AS meeting_id,
        'USER_003' AS user_id,
        CURRENT_TIMESTAMP() - INTERVAL '1 day' AS join_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 day' + INTERVAL '90 minutes' AS leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM sample_participants
