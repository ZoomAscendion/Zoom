/*
  Bronze Layer Meetings Model
  Purpose: Clean and validate meeting data from raw layer
  Source: RAW.MEETINGS
  Target: BRONZE.BZ_MEETINGS
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH raw_meetings AS (
    SELECT 
        -- Source data extraction with data quality checks
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom', 'meetings') }}
    WHERE host_id IS NOT NULL
      AND meeting_topic IS NOT NULL
      AND start_time IS NOT NULL
      AND end_time IS NOT NULL
      AND duration_minutes IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Add data quality flags
        CASE 
            WHEN start_time > end_time THEN 'INVALID_TIME_RANGE'
            WHEN duration_minutes < 0 THEN 'NEGATIVE_DURATION'
            WHEN start_time > CURRENT_TIMESTAMP() THEN 'FUTURE_MEETING'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM raw_meetings
),

final_bronze AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        host_id::STRING AS host_id,
        meeting_topic::STRING AS meeting_topic,
        start_time::TIMESTAMP_NTZ AS start_time,
        end_time::TIMESTAMP_NTZ AS end_time,
        duration_minutes::NUMBER(38,0) AS duration_minutes,
        load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
        update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
        source_system::STRING AS source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_bronze
