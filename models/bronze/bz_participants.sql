-- Bronze Layer Participants Model
-- Description: Raw participant data tracking meeting attendance
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='participant_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY participant_id 
               ORDER BY load_timestamp DESC
           ) as rn
    FROM source_data
),

-- Final transformation with data type conversions
final AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        -- Convert VARCHAR join_time to TIMESTAMP
        CASE 
            WHEN join_time IS NOT NULL AND TRIM(join_time) != ''
            THEN TRY_TO_TIMESTAMP(join_time)
            ELSE NULL
        END as join_time,
        leave_time,
        -- Overwrite timestamps with current DBT run time
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per participant_id
)

SELECT * FROM final
