-- Bronze Layer Webinars Model
-- Description: Transforms raw webinars data to bronze layer with data quality checks
-- Source: RAW.WEBINARS
-- Target: BRONZE.bz_webinars
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_webinars AS (
    SELECT 
        HOST_ID,
        WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        REGISTRANTS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'WEBINARS') }}
),

-- Data quality and cleansing transformations
cleansed_webinars AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(HOST_ID) as host_id,
        TRIM(WEBINAR_TOPIC) as webinar_topic,
        START_TIME as start_time,
        END_TIME as end_time,
        CASE 
            WHEN REGISTRANTS IS NULL THEN 0
            WHEN REGISTRANTS < 0 THEN 0
            ELSE REGISTRANTS 
        END as registrants,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM)) as source_system,
        
        -- Audit fields for bronze layer
        CURRENT_TIMESTAMP() as bronze_created_at,
        'SUCCESS' as process_status
        
    FROM raw_webinars
    WHERE HOST_ID IS NOT NULL
      AND WEBINAR_TOPIC IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
      AND START_TIME <= END_TIME  -- Business rule validation
)

-- Final select for bronze layer
SELECT 
    host_id,
    webinar_topic,
    start_time,
    end_time,
    registrants,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_webinars
