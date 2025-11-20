-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Create sample data for Bronze Meetings table
WITH sample_meetings AS (
    SELECT 
        'MEET001' as MEETING_ID,
        'USER001' as HOST_ID,
        'Weekly Team Standup' as MEETING_TOPIC,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as START_TIME,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as END_TIME,
        60 as DURATION_MINUTES,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
    
    UNION ALL
    
    SELECT 
        'MEET002' as MEETING_ID,
        'USER002' as HOST_ID,
        'Project Review Meeting' as MEETING_TOPIC,
        CURRENT_TIMESTAMP() - INTERVAL '1 day' as START_TIME,
        CURRENT_TIMESTAMP() - INTERVAL '1 day' + INTERVAL '30 minutes' as END_TIME,
        30 as DURATION_MINUTES,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
        
    UNION ALL
    
    SELECT 
        'MEET003' as MEETING_ID,
        'USER003' as HOST_ID,
        'Client Presentation' as MEETING_TOPIC,
        CURRENT_TIMESTAMP() - INTERVAL '3 hours' as START_TIME,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as END_TIME,
        60 as DURATION_MINUTES,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM sample_meetings
