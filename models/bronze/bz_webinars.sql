-- Bronze Layer Webinars Model
-- Description: Transforms raw webinars data to bronze layer with data quality checks
-- Source: RAW.WEBINARS
-- Target: BRONZE.bz_webinars
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_webinars', CURRENT_TIMESTAMP(), 'DBT', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_audit_log'",
    post_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_webinars', CURRENT_TIMESTAMP(), 'DBT', 1, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_audit_log'"
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
        TRIM(HOST_ID)::STRING as host_id,
        TRIM(WEBINAR_TOPIC)::STRING as webinar_topic,
        START_TIME::TIMESTAMP_NTZ as start_time,
        END_TIME::TIMESTAMP_NTZ as end_time,
        CASE 
            WHEN REGISTRANTS IS NULL THEN 0
            WHEN REGISTRANTS < 0 THEN 0
            ELSE REGISTRANTS 
        END::NUMBER(38,0) as registrants,
        LOAD_TIMESTAMP::TIMESTAMP_NTZ as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)::TIMESTAMP_NTZ as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM))::STRING as source_system
        
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
