-- Bronze Layer Participants Model
-- Description: Raw participant data tracking meeting attendance
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_PARTICIPANTS' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 0 as processing_time, 'STARTED' as status, 5 as record_id",
    post_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_PARTICIPANTS' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 1 as processing_time, 'COMPLETED' as status, 6 as record_id"
) }}

-- Filter out null primary keys and apply deduplication
WITH source_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        TRY_CAST(JOIN_TIME AS TIMESTAMP_NTZ(9)) as JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL  -- Filter null primary keys
      AND MEETING_ID IS NOT NULL      -- Filter null meeting IDs
      AND USER_ID IS NOT NULL         -- Filter null user IDs
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM source_data
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,    -- Overwrite with current timestamp
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,  -- Overwrite with current timestamp
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1  -- Keep only the latest record per participant
