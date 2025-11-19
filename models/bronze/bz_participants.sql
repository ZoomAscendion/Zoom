-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', DATEDIFF('seconds', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_PARTICIPANTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- CTE to filter out NULL primary keys and prepare raw data
WITH raw_participants_filtered AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        TRY_CAST(JOIN_TIME AS TIMESTAMP_NTZ(9)) AS JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) AS row_num
    FROM raw_participants_filtered
)

-- Final selection with 1-to-1 mapping from raw to bronze
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
WHERE row_num = 1
