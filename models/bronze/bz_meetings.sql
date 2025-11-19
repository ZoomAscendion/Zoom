-- Bronze Layer Meetings Model
-- Description: Raw meeting information and session details from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings']
) }}

-- Raw data selection with primary key filtering
WITH raw_meetings AS (
    SELECT *
    FROM {{ source('raw_schema', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and load timestamp
deduped_meetings AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY meeting_id 
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM raw_meetings
),

-- Final transformation with 1-1 mapping and data type conversion
final_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) AS end_time,
        TRY_CAST(duration_minutes AS NUMBER(38,0)) AS duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_meetings
    WHERE row_num = 1
)

SELECT * FROM final_meetings
