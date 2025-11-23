{{
  config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_JOB', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="UPDATE {{ ref('bz_data_audit') }} SET processing_time = DATEDIFF('second', load_timestamp, CURRENT_TIMESTAMP()), status = 'SUCCESS' WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED' AND '{{ this.name }}' != 'bz_data_audit'"
  )
}}

-- Bronze layer transformation for PARTICIPANTS table
-- Applies data cleaning, validation, and deduplication
-- Maps raw participant data to bronze layer with audit information

WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter out records with null primary key
      AND meeting_id IS NOT NULL     -- Filter out records with null meeting_id
      AND user_id IS NOT NULL       -- Filter out records with null user_id
),

-- Apply deduplication based on primary key, keeping the most recent record
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY load_timestamp DESC) as rn
    FROM source_data
),

-- Final transformation with data quality enhancements
final_data AS (
    SELECT
        participant_id,
        meeting_id,
        user_id,
        CASE 
            WHEN join_time IS NULL OR join_time = '' THEN NULL
            ELSE TRY_CAST(join_time AS TIMESTAMP_NTZ(9))
        END AS join_time,
        leave_time,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per participant_id
)

SELECT * FROM final_data
