/*
  Bronze Webinars Model
  Purpose: Transform raw webinars data to bronze layer
  Source: RAW.WEBINARS
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'webinars') }}
),

-- Data validation and cleansing
cleansed_data AS (
    SELECT
        -- Business fields with data validation
        COALESCE(TRIM(host_id), 'UNKNOWN') AS host_id,
        COALESCE(TRIM(webinar_topic), 'UNKNOWN') AS webinar_topic,
        COALESCE(start_time, CURRENT_TIMESTAMP()) AS start_time,
        COALESCE(end_time, CURRENT_TIMESTAMP()) AS end_time,
        COALESCE(registrants, 0) AS registrants,
        
        -- Audit fields
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(TRIM(source_system), 'UNKNOWN') AS source_system,
        
        -- Process metadata
        CURRENT_TIMESTAMP() AS bronze_created_at,
        'SUCCESS' AS process_status
        
    FROM source_data
    WHERE host_id IS NOT NULL  -- Basic data quality check
)

SELECT
    host_id::STRING AS host_id,
    webinar_topic::STRING AS webinar_topic,
    start_time::TIMESTAMP_NTZ AS start_time,
    end_time::TIMESTAMP_NTZ AS end_time,
    registrants::NUMBER(38,0) AS registrants,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
    source_system::STRING AS source_system
FROM cleansed_data
