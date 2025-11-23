-- Bronze Layer Meetings Model
-- Description: Raw meeting data including scheduling and basic meeting information
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='meeting_id'
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY meeting_id 
               ORDER BY load_timestamp DESC
           ) as rn
    FROM source_data
),

-- Final transformation with data type conversions
final AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        -- Convert VARCHAR end_time to TIMESTAMP
        CASE 
            WHEN end_time IS NOT NULL AND TRIM(end_time) != ''
            THEN TRY_TO_TIMESTAMP(end_time)
            ELSE NULL
        END as end_time,
        -- Convert VARCHAR duration_minutes to NUMBER
        CASE 
            WHEN duration_minutes IS NOT NULL AND TRIM(duration_minutes) != ''
            THEN TRY_TO_NUMBER(duration_minutes)
            ELSE NULL
        END as duration_minutes,
        -- Overwrite timestamps with current DBT run time
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per meeting_id
)

SELECT * FROM final
