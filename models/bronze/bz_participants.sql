-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    -- Select from raw participants table with null filtering for primary key
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication logic
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) AS rn
    FROM source_data
)

-- Final select with 1-1 mapping from raw to bronze
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1
