-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_PARTICIPANTS',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                0,
                'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_PARTICIPANTS',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                DATEDIFF('seconds', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ),
                'SUCCESS'
        {% endif %}
    "
) }}

-- Raw data selection with null filtering for primary key
WITH raw_participants AS (
    SELECT *
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and latest timestamp
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY participant_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM raw_participants
),

-- Final transformation with data type conversions and bronze timestamp overwrite
final_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        TRY_CAST(join_time AS TIMESTAMP_NTZ(9)) AS join_time,  -- Convert VARCHAR to TIMESTAMP
        leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run timestamp
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run timestamp
        source_system
    FROM deduped_participants
    WHERE row_num = 1
)

SELECT * FROM final_participants
