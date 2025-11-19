-- Bronze Layer Participants Model
-- Description: Raw meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='participant_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        TRY_CAST(join_time AS TIMESTAMP_NTZ(9)) AS join_time,  -- Handle VARCHAR to TIMESTAMP conversion
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY participant_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) as rn
    FROM source_data
)

-- Final selection with 1-to-1 mapping from raw to bronze
SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
WHERE rn = 1
