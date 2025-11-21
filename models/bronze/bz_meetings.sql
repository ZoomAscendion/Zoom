-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='meeting_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- CTE to select and filter raw data
WITH raw_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out NULL primary keys
      AND host_id IS NOT NULL    -- Filter out NULL foreign keys
),

-- CTE for deduplication based on meeting_id and latest update_timestamp
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) as rn
    FROM raw_meetings
),

-- CTE for data quality and transformation
cleaned_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        CASE 
            WHEN end_time IS NULL OR end_time = '' THEN NULL
            ELSE TRY_TO_TIMESTAMP(end_time)
        END as end_time,
        CASE 
            WHEN duration_minutes IS NULL OR duration_minutes = '' THEN NULL
            ELSE TRY_TO_NUMBER(duration_minutes)
        END as duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_meetings
    WHERE rn = 1
)

-- Final SELECT with audit columns
SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleaned_meetings
