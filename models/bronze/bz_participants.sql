-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: DBT Pipeline Generator
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='participant_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 0, 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', DATEDIFF('second', 
            (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'), 
            CURRENT_TIMESTAMP()), 'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from raw participants table with null filtering for primary key
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        TRY_CAST(join_time AS TIMESTAMP_NTZ(9)) AS join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_layer', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY participant_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM source_data
    )
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
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
