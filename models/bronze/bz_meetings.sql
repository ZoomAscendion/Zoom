-- Bronze Layer Meetings Model
-- Description: Transforms raw meeting data into bronze layer with audit capabilities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='meeting_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH raw_meetings AS (
    -- Select from raw meetings table with null filtering for primary key
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
    FROM {{ source('raw', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
      AND START_TIME IS NOT NULL
),

deduped_meetings AS (
    -- Apply deduplication based on meeting_id, keeping the latest record
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC) as rn
        FROM raw_meetings
    )
    WHERE rn = 1
),

final_meetings AS (
    -- Final transformation with data type conversions
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        TRY_CAST(END_TIME AS TIMESTAMP_NTZ) AS END_TIME,
        TRY_CAST(DURATION_MINUTES AS NUMBER) AS DURATION_MINUTES,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'unknown') AS SOURCE_SYSTEM
    FROM deduped_meetings
)

SELECT * FROM final_meetings
