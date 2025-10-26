/*
  Bronze Layer Webinars Model
  Purpose: Clean and validate webinar data from raw layer
  Source: RAW.WEBINARS
  Target: BRONZE.BZ_WEBINARS
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH raw_webinars AS (
    SELECT 
        -- Source data extraction with data quality checks
        host_id,
        webinar_topic,
        start_time,
        end_time,
        registrants,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom', 'webinars') }}
    WHERE host_id IS NOT NULL
      AND webinar_topic IS NOT NULL
      AND start_time IS NOT NULL
      AND end_time IS NOT NULL
      AND registrants IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Add data quality flags
        CASE 
            WHEN start_time > end_time THEN 'INVALID_TIME_RANGE'
            WHEN registrants < 0 THEN 'NEGATIVE_REGISTRANTS'
            WHEN start_time > CURRENT_TIMESTAMP() THEN 'FUTURE_WEBINAR'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM raw_webinars
),

final_bronze AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        host_id::STRING AS host_id,
        webinar_topic::STRING AS webinar_topic,
        start_time::TIMESTAMP_NTZ AS start_time,
        end_time::TIMESTAMP_NTZ AS end_time,
        registrants::NUMBER(38,0) AS registrants,
        load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
        update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
        source_system::STRING AS source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_bronze
