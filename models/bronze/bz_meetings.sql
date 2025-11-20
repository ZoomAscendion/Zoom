-- Bronze Layer Meetings Model
-- Description: Transforms raw meeting data to bronze layer with data quality checks
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings']
) }}

-- CTE to filter out null primary keys and prepare raw data
WITH raw_meetings_filtered AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        -- Convert END_TIME from VARCHAR to TIMESTAMP_NTZ if not null
        CASE 
            WHEN END_TIME IS NOT NULL AND END_TIME != '' 
            THEN TRY_TO_TIMESTAMP_NTZ(END_TIME)
            ELSE NULL 
        END as END_TIME,
        -- Convert DURATION_MINUTES from VARCHAR to NUMBER if not null
        CASE 
            WHEN DURATION_MINUTES IS NOT NULL AND DURATION_MINUTES != '' 
            THEN TRY_TO_NUMBER(DURATION_MINUTES)
            ELSE NULL 
        END as DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM raw_meetings_filtered
)

-- Final selection with 1-1 mapping from raw to bronze
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
FROM deduped_meetings
WHERE rn = 1  -- Keep only the most recent record for each meeting
