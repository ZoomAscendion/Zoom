/*
  Bronze Layer Participants Model
  Purpose: Clean and validate participant data from raw layer
  Source: RAW.PARTICIPANTS
  Target: BRONZE.BZ_PARTICIPANTS
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH raw_participants AS (
    SELECT 
        -- Source data extraction with data quality checks
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom', 'participants') }}
    WHERE meeting_id IS NOT NULL
      AND user_id IS NOT NULL
      AND join_time IS NOT NULL
      AND leave_time IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Add data quality flags
        CASE 
            WHEN join_time > leave_time THEN 'INVALID_TIME_RANGE'
            WHEN join_time > CURRENT_TIMESTAMP() THEN 'FUTURE_JOIN'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM raw_participants
),

final_bronze AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        meeting_id::STRING AS meeting_id,
        user_id::STRING AS user_id,
        join_time::TIMESTAMP_NTZ AS join_time,
        leave_time::TIMESTAMP_NTZ AS leave_time,
        load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
        update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
        source_system::STRING AS source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_bronze
