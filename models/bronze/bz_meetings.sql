-- Bronze Layer Meetings Table
-- Description: Raw meeting information and session details
-- Source: RAW.MEETINGS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='meeting_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'dbt_user', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

-- Source data with null filtering for primary key
WITH source_data AS (
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
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out null primary keys
      AND host_id IS NOT NULL     -- Filter out null host_id
      AND start_time IS NOT NULL  -- Filter out null start_time
),

-- Data cleaning and validation
cleaned_data AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) AS end_time,  -- Handle string to timestamp conversion
        TRY_CAST(duration_minutes AS NUMBER(38,0)) AS duration_minutes,  -- Handle string to number conversion
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
),

-- Deduplication based on meeting_id (keeping latest record)
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS rn
    FROM cleaned_data
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
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_data
WHERE rn = 1
