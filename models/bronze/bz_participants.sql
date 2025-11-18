-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'participants']
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY PARTICIPANT_ID 
               ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) AS row_num
    FROM source_data
),

transformed_data AS (
    -- Handle data type conversions for Bronze layer
    SELECT
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Convert JOIN_TIME from VARCHAR to TIMESTAMP_NTZ if not null
        CASE 
            WHEN JOIN_TIME IS NOT NULL AND JOIN_TIME != '' 
            THEN TRY_TO_TIMESTAMP_NTZ(JOIN_TIME)
            ELSE NULL 
        END AS JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        row_num
    FROM deduped_data
)

-- Final selection with 1-1 mapping from RAW to Bronze
SELECT
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM transformed_data
WHERE row_num = 1
