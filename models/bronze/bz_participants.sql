-- Bronze Layer Participants Model
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="
        {% if target.name != 'audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 
               DATEDIFF('seconds', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_PARTICIPANTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 
               'COMPLETED'
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        TRY_CAST(JOIN_TIME AS TIMESTAMP_NTZ(9)) as JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL  -- Filter out records with null primary key
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY PARTICIPANT_ID 
                   ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
               ) as rn
        FROM source_data
    )
    WHERE rn = 1
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
