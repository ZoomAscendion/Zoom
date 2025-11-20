-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Create sample data for Bronze Participants table
WITH sample_participants AS (
    SELECT 
        'PART001' as PARTICIPANT_ID,
        'MEET001' as MEETING_ID,
        'USER001' as USER_ID,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' as JOIN_TIME,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as LEAVE_TIME,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
    
    UNION ALL
    
    SELECT 
        'PART002' as PARTICIPANT_ID,
        'MEET001' as MEETING_ID,
        'USER002' as USER_ID,
        CURRENT_TIMESTAMP() - INTERVAL '2 hours' + INTERVAL '5 minutes' as JOIN_TIME,
        CURRENT_TIMESTAMP() - INTERVAL '1 hour' as LEAVE_TIME,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
        
    UNION ALL
    
    SELECT 
        'PART003' as PARTICIPANT_ID,
        'MEET002' as MEETING_ID,
        'USER003' as USER_ID,
        CURRENT_TIMESTAMP() - INTERVAL '1 day' as JOIN_TIME,
        CURRENT_TIMESTAMP() - INTERVAL '1 day' + INTERVAL '30 minutes' as LEAVE_TIME,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM sample_participants
