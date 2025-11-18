-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ({{ range(1, 1000000) | random }}, 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ({{ range(1, 1000000) | random }}, 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'COMPLETED')"
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY MEETING_ID 
               ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) AS row_num
    FROM source_data
),

transformed_data AS (
    -- Handle data type conversions for Bronze layer
    SELECT
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        -- Convert END_TIME from VARCHAR to TIMESTAMP_NTZ if not null
        CASE 
            WHEN END_TIME IS NOT NULL AND END_TIME != '' 
            THEN TRY_TO_TIMESTAMP_NTZ(END_TIME)
            ELSE NULL 
        END AS END_TIME,
        -- Convert DURATION_MINUTES from VARCHAR to NUMBER if not null
        CASE 
            WHEN DURATION_MINUTES IS NOT NULL AND DURATION_MINUTES != '' 
            THEN TRY_TO_NUMBER(DURATION_MINUTES)
            ELSE NULL 
        END AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        row_num
    FROM deduped_data
)

-- Final selection with 1-1 mapping from RAW to Bronze
SELECT
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM transformed_data
WHERE row_num = 1
