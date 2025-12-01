-- Bronze Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create sample data structure for participants table
SELECT 
    'PARTICIPANT_001' as PARTICIPANT_ID,
    'MEETING_001' as MEETING_ID,
    'USER_001' as USER_ID,
    CURRENT_TIMESTAMP() as JOIN_TIME,
    CURRENT_TIMESTAMP() as LEAVE_TIME,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    'SAMPLE_SYSTEM' as SOURCE_SYSTEM
WHERE FALSE -- This ensures the table is created but empty initially
