-- Bronze Layer Participants Model
-- Description: Transforms raw participants data to bronze layer with data quality checks
-- Source: RAW.PARTICIPANTS
-- Target: BRONZE.bz_participants
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_participants', CURRENT_TIMESTAMP(), 'DBT', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_audit_log'",
    post_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_participants', CURRENT_TIMESTAMP(), 'DBT', 1, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_audit_log'"
) }}

WITH raw_participants AS (
    SELECT 
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'PARTICIPANTS') }}
),

-- Data quality and cleansing transformations
cleansed_participants AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(MEETING_ID)::STRING as meeting_id,
        TRIM(USER_ID)::STRING as user_id,
        JOIN_TIME::TIMESTAMP_NTZ as join_time,
        LEAVE_TIME::TIMESTAMP_NTZ as leave_time,
        LOAD_TIMESTAMP::TIMESTAMP_NTZ as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)::TIMESTAMP_NTZ as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM))::STRING as source_system
        
    FROM raw_participants
    WHERE MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND JOIN_TIME IS NOT NULL
      AND LEAVE_TIME IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
      AND JOIN_TIME <= LEAVE_TIME  -- Business rule validation
)

-- Final select for bronze layer
SELECT 
    meeting_id,
    user_id,
    join_time,
    leave_time,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_participants
