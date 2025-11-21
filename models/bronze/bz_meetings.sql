-- Bronze Layer Meetings Table
-- Description: Transforms raw meeting data into bronze layer with data quality checks and deduplication
-- Source: RAW.MEETINGS
-- Target: BRONZE.BZ_MEETINGS
-- Author: DBT Bronze Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_meetings_filtered AS (
    -- Filter out records with NULL primary keys
    SELECT *
    FROM {{ source('raw_zoom', 'meetings') }}
    WHERE meeting_id IS NOT NULL
),

raw_meetings_deduplicated AS (
    -- Apply deduplication logic based on primary key and latest update timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY meeting_id 
               ORDER BY update_timestamp DESC, load_timestamp DESC
           ) AS row_num
    FROM raw_meetings_filtered
),

raw_meetings_clean AS (
    -- Select only the most recent record for each meeting
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        source_system
    FROM raw_meetings_deduplicated
    WHERE row_num = 1
),

final_meetings AS (
    -- Apply Bronze layer transformations and add audit columns
    SELECT 
        -- Primary business columns (1-1 mapping from RAW)
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        
        -- Bronze layer audit columns (overwrite with current timestamp)
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        
        -- Source system tracking
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM raw_meetings_clean
)

SELECT *
FROM final_meetings
