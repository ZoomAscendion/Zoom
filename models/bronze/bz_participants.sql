-- Bronze Layer Participants Table
-- Description: Raw meeting participants and their session details from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ target.database }}.{{ target.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED'{% endif %}",
    post_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ target.database }}.{{ target.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1, 'SUCCESS'{% endif %}"
) }}

-- CTE for data deduplication
WITH deduplicated_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Use ROW_NUMBER to identify duplicates based on PARTICIPANT_ID and UPDATE_TIMESTAMP
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
    FROM {{ source('raw', 'participants') }}
)

-- Final selection with data validation and cleansing
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduplicated_participants
WHERE rn = 1  -- Keep only the most recent record for each PARTICIPANT_ID
  AND PARTICIPANT_ID IS NOT NULL  -- Ensure primary key is not null
  AND MEETING_ID IS NOT NULL      -- Ensure required field is not null
  AND USER_ID IS NOT NULL         -- Ensure required field is not null
