-- Bronze Layer Meetings Model
-- Description: Raw meeting data including scheduling and basic meeting information
-- Source: RAW.MEETINGS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'dbt_user', 'STARTED') WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS') WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        CASE 
            WHEN end_time IS NOT NULL AND end_time != '' 
            THEN TRY_CAST(end_time AS TIMESTAMP_NTZ(9))
            ELSE NULL 
        END AS end_time,
        CASE 
            WHEN duration_minutes IS NOT NULL AND duration_minutes != '' 
            THEN TRY_CAST(duration_minutes AS NUMBER(38,0))
            ELSE NULL 
        END AS duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out NULL primary keys
      AND host_id IS NOT NULL    -- Filter out NULL required fields
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) AS row_num
    FROM raw_meetings
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM deduped_meetings
WHERE row_num = 1
