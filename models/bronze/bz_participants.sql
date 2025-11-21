-- Bronze Layer Participants Table
-- Description: Transforms raw participant data into bronze layer with data quality checks and deduplication
-- Source: RAW.PARTICIPANTS
-- Target: BRONZE.BZ_PARTICIPANTS
-- Author: DBT Bronze Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('bz_participants', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('bz_participants', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'COMPLETED')"
) }}

WITH raw_participants_filtered AS (
    -- Filter out records with NULL primary keys
    SELECT *
    FROM {{ source('raw_zoom', 'participants') }}
    WHERE participant_id IS NOT NULL
),

raw_participants_deduplicated AS (
    -- Apply deduplication logic based on primary key and latest update timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY participant_id 
               ORDER BY COALESCE(update_timestamp, load_timestamp, CURRENT_TIMESTAMP()) DESC
           ) AS row_num
    FROM raw_participants_filtered
),

raw_participants_clean AS (
    -- Select only the most recent record for each participant
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        source_system
    FROM raw_participants_deduplicated
    WHERE row_num = 1
),

final_participants AS (
    -- Apply Bronze layer transformations and add audit columns
    SELECT 
        -- Primary business columns (1-1 mapping from RAW)
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        
        -- Bronze layer audit columns (overwrite with current timestamp)
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        
        -- Source system tracking
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM raw_participants_clean
)

SELECT *
FROM final_participants
