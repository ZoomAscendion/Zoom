-- Bronze Layer Participants Table
-- Description: Raw participant data tracking meeting attendance
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ target.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ target.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', 10, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        CASE 
            WHEN join_time IS NULL OR join_time = '' THEN NULL
            ELSE TRY_CAST(join_time AS TIMESTAMP_NTZ(9))
        END AS join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter out NULL primary keys
      AND meeting_id IS NOT NULL      -- Filter out NULL meeting_id
      AND user_id IS NOT NULL         -- Filter out NULL user_id
),

-- CTE for deduplication based on primary key
deduped_participants AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY load_timestamp DESC) as rn
    FROM raw_participants
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    CURRENT_TIMESTAMP() AS load_timestamp,    -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_participants
WHERE rn = 1  -- Keep only the most recent record per participant_id
