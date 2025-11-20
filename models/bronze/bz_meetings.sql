-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_MEETINGS' AND STATUS = 'STARTED' AND LOAD_TIMESTAMP > CURRENT_TIMESTAMP() - INTERVAL '1 MINUTE')
    ",
    post_hook="
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
               DATEDIFF('second', 
                   (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_MEETINGS' AND STATUS = 'STARTED'), 
                   CURRENT_TIMESTAMP()), 'SUCCESS'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_MEETINGS' AND STATUS = 'SUCCESS' AND LOAD_TIMESTAMP > CURRENT_TIMESTAMP() - INTERVAL '1 MINUTE')
    "
) }}

-- CTE to filter out NULL primary keys and prepare raw data
WITH source_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        TRY_CAST(END_TIME AS TIMESTAMP_NTZ(9)) AS END_TIME,  -- Convert VARCHAR to TIMESTAMP
        TRY_CAST(DURATION_MINUTES AS NUMBER(38,0)) AS DURATION_MINUTES,  -- Convert VARCHAR to NUMBER
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL  -- Filter out NULL primary keys
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM source_data
)

-- Final selection with 1:1 mapping from raw to bronze
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
FROM deduped_data
WHERE row_num = 1
