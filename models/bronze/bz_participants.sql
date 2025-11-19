-- Bronze Layer Participants Model
-- Description: Raw meeting participants and their session details from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants']
) }}

-- Raw data selection with primary key filtering
WITH raw_participants AS (
    SELECT *
    FROM {{ source('raw_schema', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and load timestamp
deduped_participants AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY participant_id 
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM raw_participants
),

-- Final transformation with 1-1 mapping and data type conversion
final_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        TRY_CAST(join_time AS TIMESTAMP_NTZ(9)) AS join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_participants
    WHERE row_num = 1
)

SELECT * FROM final_participants
