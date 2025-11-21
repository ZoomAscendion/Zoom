-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Source: RAW.MEETINGS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='meeting_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out records with null primary keys
      AND host_id IS NOT NULL    -- Filter out records with null host_id
),

-- CTE for data cleaning and validation
cleaned_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) AS end_time,
        TRY_CAST(duration_minutes AS NUMBER(38,0)) AS duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY load_timestamp DESC) AS row_num
    FROM raw_meetings
),

-- CTE for deduplication
deduped_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM cleaned_meetings
    WHERE row_num = 1  -- Keep only the latest record for each meeting_id
)

-- Final SELECT with Bronze timestamp overwrite
SELECT 
    meeting_id::VARCHAR(16777216) AS meeting_id,
    host_id::VARCHAR(16777216) AS host_id,
    meeting_topic::VARCHAR(16777216) AS meeting_topic,
    start_time::TIMESTAMP_NTZ(9) AS start_time,
    end_time::TIMESTAMP_NTZ(9) AS end_time,
    duration_minutes::NUMBER(38,0) AS duration_minutes,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system::VARCHAR(16777216) AS source_system
FROM deduped_meetings
