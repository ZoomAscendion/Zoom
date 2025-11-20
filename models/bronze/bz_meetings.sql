-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, status) SELECT COALESCE((SELECT MAX(record_id) FROM {{ ref('bz_data_audit') }}) + 1, 1), 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status) SELECT COALESCE((SELECT MAX(record_id) FROM {{ ref('bz_data_audit') }}) + 1, 1), 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'SUCCESS'"
) }}

WITH source_data AS (
    -- Select from raw meetings table with null filtering for primary key
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) AS end_time,
        TRY_CAST(duration_minutes AS NUMBER(38,0)) AS duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out records with null primary key
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY meeting_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
)

-- Final select with 1-1 mapping from raw to bronze
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
FROM deduped_data
