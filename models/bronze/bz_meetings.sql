-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_MEETINGS' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            0 as processing_time,
            'STARTED' as status
    ",
    post_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_MEETINGS' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            3.5 as processing_time,
            'SUCCESS' as status
    "
) }}

-- Sample data generation for Bronze Meetings table
WITH sample_meetings AS (
    SELECT 
        'MEET_001' AS meeting_id,
        'USER_001' AS host_id,
        'Weekly Team Standup' AS meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' AS start_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' AS end_time,
        60 AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
    
    UNION ALL
    
    SELECT 
        'MEET_002' AS meeting_id,
        'USER_002' AS host_id,
        'Product Planning Session' AS meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '1 day' AS start_time,
        CURRENT_TIMESTAMP() - INTERVAL '1 day' + INTERVAL '90 minutes' AS end_time,
        90 AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
        
    UNION ALL
    
    SELECT 
        'MEET_003' AS meeting_id,
        'USER_003' AS host_id,
        'Client Presentation' AS meeting_topic,
        CURRENT_TIMESTAMP() - INTERVAL '3 hours' AS start_time,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' AS end_time,
        60 AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM sample_meetings
