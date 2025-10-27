-- Bronze Layer Meetings Model
-- Description: Transforms raw meetings data to bronze layer with data quality checks
-- Source: RAW.MEETINGS
-- Target: BRONZE.bz_meetings
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_meetings', CURRENT_TIMESTAMP(), 'DBT', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_audit_log'",
    post_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_meetings', CURRENT_TIMESTAMP(), 'DBT', 1, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_audit_log'"
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
        TRIM(HOST_ID)::STRING as host_id,
        TRIM(MEETING_TOPIC)::STRING as meeting_topic,
        START_TIME::TIMESTAMP_NTZ as start_time,
        END_TIME::TIMESTAMP_NTZ as end_time,
        CASE 
            WHEN DURATION_MINUTES IS NULL THEN 0
            WHEN DURATION_MINUTES < 0 THEN 0
            ELSE DURATION_MINUTES 
        END::NUMBER(38,0) as duration_minutes,
        LOAD_TIMESTAMP::TIMESTAMP_NTZ as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)::TIMESTAMP_NTZ as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM))::STRING as source_system
        
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
