-- Bronze Layer Meetings Model
-- Description: Raw meeting data including scheduling and basic meeting information
-- Author: Data Engineer
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_USER', 1, 'SUCCESS')"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY meeting_id 
               ORDER BY load_timestamp DESC
           ) AS row_num
    FROM source_data
),

-- Final transformation with bronze timestamp overwrite
final AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        CASE 
            WHEN end_time IS NULL OR end_time = '' THEN NULL
            ELSE TRY_CAST(end_time AS TIMESTAMP_NTZ(9))
        END AS end_time,
        CASE 
            WHEN duration_minutes IS NULL OR duration_minutes = '' THEN 0
            ELSE TRY_CAST(duration_minutes AS NUMBER(38,0))
        END AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'unknown') AS source_system
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM final
