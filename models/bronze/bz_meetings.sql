-- Bronze Layer Meetings Model
-- Description: Raw meeting data including scheduling and basic meeting information
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_MEETINGS' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 0 as processing_time, 'STARTED' as status, 3 as record_id",
    post_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_MEETINGS' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 1 as processing_time, 'COMPLETED' as status, 4 as record_id"
) }}

-- Filter out null primary keys and apply deduplication
WITH source_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        TRY_CAST(END_TIME AS TIMESTAMP_NTZ(9)) as END_TIME,
        TRY_CAST(DURATION_MINUTES AS NUMBER(38,0)) as DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL  -- Filter null primary keys
      AND HOST_ID IS NOT NULL     -- Filter null host IDs
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM source_data
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,    -- Overwrite with current timestamp
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,  -- Overwrite with current timestamp
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1  -- Keep only the latest record per meeting
