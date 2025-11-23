{{
  config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_JOB', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="UPDATE {{ ref('bz_data_audit') }} SET processing_time = DATEDIFF('second', load_timestamp, CURRENT_TIMESTAMP()), status = 'SUCCESS' WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED' AND '{{ this.name }}' != 'bz_data_audit'"
  )
}}

-- Bronze layer transformation for MEETINGS table
-- Applies data cleaning, validation, and deduplication
-- Maps raw meeting data to bronze layer with audit information

WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out records with null primary key
      AND host_id IS NOT NULL    -- Filter out records with null host_id
      AND start_time IS NOT NULL -- Filter out records with null start_time
),

-- Apply deduplication based on primary key, keeping the most recent record
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY load_timestamp DESC) as rn
    FROM source_data
),

-- Final transformation with data quality enhancements
final_data AS (
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
            WHEN duration_minutes IS NULL OR duration_minutes = '' THEN NULL
            ELSE TRY_CAST(duration_minutes AS NUMBER(38,0))
        END AS duration_minutes,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per meeting_id
)

SELECT * FROM final_data
