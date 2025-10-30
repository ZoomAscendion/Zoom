-- Bronze Layer Meetings Model
-- Transforms raw meeting data from RAW.MEETINGS to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- CTE for raw data extraction
WITH raw_meetings AS (
    SELECT 
        -- Business columns from source
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'meetings') }}
),

-- CTE for data validation and cleansing
validated_meetings AS (
    SELECT 
        -- Apply data quality checks and preserve original structure
        COALESCE(MEETING_ID, 'UNKNOWN') as MEETING_ID,
        COALESCE(HOST_ID, 'UNKNOWN') as HOST_ID,
        COALESCE(MEETING_TOPIC, 'UNKNOWN') as MEETING_TOPIC,
        START_TIME,
        END_TIME,
        COALESCE(DURATION_MINUTES, 0) as DURATION_MINUTES,
        
        -- Metadata preservation
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) as LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) as UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') as SOURCE_SYSTEM
        
    FROM raw_meetings
)

-- Final selection for Bronze layer
SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_meetings
