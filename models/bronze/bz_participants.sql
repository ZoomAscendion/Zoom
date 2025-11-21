-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} 
            (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                'BZ_PARTICIPANTS' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                'DBT_{{ invocation_id }}' as processed_by,
                0 as processing_time,
                'STARTED' as status
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} 
            (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                'BZ_PARTICIPANTS' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                'DBT_{{ invocation_id }}' as processed_by,
                DATEDIFF('second', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ) as processing_time,
                'SUCCESS' as status
        {% endif %}
    "
) }}

-- Raw data selection with null filtering for primary keys
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
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter out records with null primary keys
),

-- Deduplication logic based on primary key and latest timestamp
deduped_participants AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY participant_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM raw_participants
    )
    WHERE rn = 1
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM deduped_participants
