-- Bronze Layer Participants Model
-- Description: Transforms raw participant data to bronze layer with data quality checks
-- Author: Data Engineering Team

{{ config(
    materialized='table',
    tags=['bronze', 'participants']
) }}

-- CTE to filter out null primary keys and prepare raw data
WITH raw_participants_filtered AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Handle JOIN_TIME conversion safely
        CASE 
            WHEN JOIN_TIME IS NOT NULL AND TRIM(JOIN_TIME) != '' 
            THEN TRY_CAST(JOIN_TIME AS TIMESTAMP_NTZ)
            ELSE NULL 
        END as JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM raw_participants_filtered
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_participants
WHERE rn = 1  -- Keep only the most recent record for each participant
