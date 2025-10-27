/*
  Bronze Meetings Model
  Purpose: Transform raw meetings data to bronze layer
  Source: RAW.MEETINGS
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'meetings') }}
),

-- Data validation and cleansing
cleansed_data AS (
    SELECT
        -- Business fields with data validation
        COALESCE(TRIM(host_id), 'UNKNOWN') AS host_id,
        COALESCE(TRIM(meeting_topic), 'UNKNOWN') AS meeting_topic,
        COALESCE(start_time, CURRENT_TIMESTAMP()) AS start_time,
        COALESCE(end_time, CURRENT_TIMESTAMP()) AS end_time,
        COALESCE(duration_minutes, 0) AS duration_minutes,
        
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
    meeting_topic::STRING AS meeting_topic,
    start_time::TIMESTAMP_NTZ AS start_time,
    end_time::TIMESTAMP_NTZ AS end_time,
    duration_minutes::NUMBER(38,0) AS duration_minutes,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
    source_system::STRING AS source_system
FROM cleansed_data
