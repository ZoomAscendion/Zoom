-- Bronze Layer Participants Table
-- Description: Raw meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='participant_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

WITH source_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        TRY_CAST(JOIN_TIME AS TIMESTAMP_NTZ) as JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP as raw_load_timestamp,
        UPDATE_TIMESTAMP as raw_update_timestamp,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL  -- Filter out NULL primary keys
      AND MEETING_ID IS NOT NULL      -- Filter out NULL foreign keys
      AND USER_ID IS NOT NULL         -- Filter out NULL foreign keys
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY COALESCE(raw_update_timestamp, raw_load_timestamp) DESC
        ) as row_num
    FROM source_data
),

-- Handle null values and apply business rules
cleaned_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Bronze timestamp overwrite
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Bronze timestamp overwrite
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM cleaned_data
