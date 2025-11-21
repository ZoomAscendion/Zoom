-- Bronze Layer Meetings Table
-- Description: Raw meeting information and session details
-- Author: Data Engineering Team

{{ config(
    materialized='table'
) }}

-- CTE to select and filter raw data
WITH raw_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        CASE 
            WHEN end_time IS NULL OR end_time = '' THEN NULL
            ELSE TRY_CAST(end_time AS TIMESTAMP_NTZ(9))
        END AS end_time,
        CASE 
            WHEN duration_minutes IS NULL OR duration_minutes = '' THEN NULL
            ELSE TRY_CAST(duration_minutes AS NUMBER(38,0))
        END AS duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out NULL primary keys
      AND host_id IS NOT NULL    -- Filter out NULL host_id
      AND start_time IS NOT NULL -- Filter out NULL start_time
),

-- CTE for deduplication based on primary key
deduped_meetings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY load_timestamp DESC) as rn
    FROM raw_meetings
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    CURRENT_TIMESTAMP() AS load_timestamp,    -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_meetings
WHERE rn = 1  -- Keep only the most recent record per meeting_id
