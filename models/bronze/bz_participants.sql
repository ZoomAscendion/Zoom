-- Bronze Layer Participants Model
-- Description: Raw participant data tracking meeting attendance
-- Author: Data Engineer
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', 1, 'SUCCESS')"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY participant_id 
               ORDER BY load_timestamp DESC
           ) AS row_num
    FROM source_data
),

-- Final transformation with bronze timestamp overwrite
final AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        CASE 
            WHEN join_time IS NULL OR join_time = '' THEN NULL
            ELSE TRY_CAST(join_time AS TIMESTAMP_NTZ(9))
        END AS join_time,
        leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'unknown') AS source_system
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM final
