-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

WITH source_data AS (
    -- Select from raw source table with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
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

-- Final select with bronze timestamp overwrite
SELECT
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system
FROM deduped_data
