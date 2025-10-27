-- Bronze Layer Meetings Model
-- Description: Transforms raw meetings data to bronze layer with data quality checks
-- Source: RAW.MEETINGS
-- Target: BRONZE.bz_meetings
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_meetings AS (
    SELECT 
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'MEETINGS') }}
),

-- Data quality and cleansing transformations
cleansed_meetings AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(HOST_ID) as host_id,
        TRIM(MEETING_TOPIC) as meeting_topic,
        START_TIME as start_time,
        END_TIME as end_time,
        CASE 
            WHEN DURATION_MINUTES IS NULL THEN 0
            WHEN DURATION_MINUTES < 0 THEN 0
            ELSE DURATION_MINUTES 
        END as duration_minutes,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM)) as source_system,
        
        -- Audit fields for bronze layer
        CURRENT_TIMESTAMP() as bronze_created_at,
        'SUCCESS' as process_status
        
    FROM raw_meetings
    WHERE HOST_ID IS NOT NULL
      AND MEETING_TOPIC IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
      AND START_TIME <= END_TIME  -- Business rule validation
)

-- Final select for bronze layer
SELECT 
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_meetings
