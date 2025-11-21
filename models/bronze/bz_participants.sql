-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Source: RAW.PARTICIPANTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='participant_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter out records with null primary keys
      AND meeting_id IS NOT NULL     -- Filter out records with null meeting_id
      AND user_id IS NOT NULL        -- Filter out records with null user_id
),

-- CTE for data cleaning and validation
cleaned_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        TRY_CAST(join_time AS TIMESTAMP_NTZ(9)) AS join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY load_timestamp DESC) AS row_num
    FROM raw_participants
),

-- CTE for deduplication
deduped_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM cleaned_participants
    WHERE row_num = 1  -- Keep only the latest record for each participant_id
)

-- Final SELECT with Bronze timestamp overwrite
SELECT 
    participant_id::VARCHAR(16777216) AS participant_id,
    meeting_id::VARCHAR(16777216) AS meeting_id,
    user_id::VARCHAR(16777216) AS user_id,
    join_time::TIMESTAMP_NTZ(9) AS join_time,
    leave_time::TIMESTAMP_NTZ(9) AS leave_time,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system::VARCHAR(16777216) AS source_system
FROM deduped_participants
