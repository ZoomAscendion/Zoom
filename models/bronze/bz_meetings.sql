-- Bronze Layer Meetings Model
-- Description: Raw meeting information and session details
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'dbt_user', 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY meeting_id 
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM source_data
)

-- Final selection with 1-to-1 mapping from raw to bronze
SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) AS end_time,  -- Handle VARCHAR to TIMESTAMP conversion
    TRY_CAST(duration_minutes AS NUMBER(38,0)) AS duration_minutes,  -- Handle VARCHAR to NUMBER conversion
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
WHERE row_num = 1
