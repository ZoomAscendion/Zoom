-- Bronze Pipeline Step 4: Transform raw participants data to bronze layer
-- Description: 1-1 mapping from RAW.PARTICIPANTS to BRONZE.BZ_PARTICIPANTS with deduplication
-- Author: Data Engineering Team
-- Created: 2024-01-01

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Bronze Pipeline Step 4.1: Select and filter raw data excluding null primary keys
WITH raw_participants_filtered AS (
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
    WHERE participant_id IS NOT NULL  -- Filter out null primary keys
),

-- Bronze Pipeline Step 4.2: Apply deduplication logic based on primary key and latest timestamp
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY participant_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) as rn
    FROM raw_participants_filtered
),

-- Bronze Pipeline Step 4.3: Select final deduplicated records
final_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_participants
    WHERE rn = 1
)

SELECT * FROM final_participants
