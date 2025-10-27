/*
  Bronze Participants Model
  Purpose: Transform raw participants data to bronze layer
  Source: RAW.PARTICIPANTS
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'participants') }}
),

-- Data validation and cleansing
cleansed_data AS (
    SELECT
        -- Business fields with data validation
        COALESCE(TRIM(meeting_id), 'UNKNOWN') AS meeting_id,
        COALESCE(TRIM(user_id), 'UNKNOWN') AS user_id,
        COALESCE(join_time, CURRENT_TIMESTAMP()) AS join_time,
        COALESCE(leave_time, CURRENT_TIMESTAMP()) AS leave_time,
        
        -- Audit fields
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(TRIM(source_system), 'UNKNOWN') AS source_system,
        
        -- Process metadata
        CURRENT_TIMESTAMP() AS bronze_created_at,
        'SUCCESS' AS process_status
        
    FROM source_data
    WHERE meeting_id IS NOT NULL AND user_id IS NOT NULL  -- Basic data quality check
)

SELECT
    meeting_id::STRING AS meeting_id,
    user_id::STRING AS user_id,
    join_time::TIMESTAMP_NTZ AS join_time,
    leave_time::TIMESTAMP_NTZ AS leave_time,
    load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
    update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
    source_system::STRING AS source_system
FROM cleansed_data
