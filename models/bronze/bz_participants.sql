-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook=[
        "{% if this.name != 'bz_data_audit' %}",
        "INSERT INTO {{ target.database }}.{{ target.schema }}.bz_data_audit (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT', 'STARTED')",
        "{% endif %}"
    ],
    post_hook=[
        "{% if this.name != 'bz_data_audit' %}",
        "INSERT INTO {{ target.database }}.{{ target.schema }}.bz_data_audit (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT', 10, 'SUCCESS')",
        "{% endif %}"
    ]
) }}

-- Raw data extraction and deduplication
WITH source_data AS (
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
),

-- Apply deduplication based on PARTICIPANT_ID and UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM source_data
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
FROM deduped_data
WHERE row_num = 1
