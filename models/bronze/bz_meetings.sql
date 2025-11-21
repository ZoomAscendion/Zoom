-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Source: RAW.MEETINGS
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status) SELECT COALESCE(MAX(record_id), 0) + 1, 'bz_meetings', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 0, 'STARTED' FROM {{ ref('bz_data_audit') }}",
    post_hook="UPDATE {{ ref('bz_data_audit') }} SET processing_time = 1.0, status = 'SUCCESS' WHERE source_table = 'bz_meetings' AND status = 'STARTED'"
) }}

WITH source_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        TRY_CAST(END_TIME AS TIMESTAMP_NTZ) AS END_TIME,
        TRY_CAST(DURATION_MINUTES AS NUMBER) AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL  -- Filter out NULL primary keys
      AND HOST_ID IS NOT NULL     -- Filter out NULL foreign keys
      AND START_TIME IS NOT NULL  -- Filter out NULL required fields
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY MEETING_ID 
                   ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
               ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

-- Final transformation with Bronze timestamp overwrite
final_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final_data
