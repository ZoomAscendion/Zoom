-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Source: RAW.PARTICIPANTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PROCESS', 0.0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PROCESS', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_PARTICIPANTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- Extract raw participant data from source system
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on PARTICIPANT_ID and UPDATE_TIMESTAMP
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM {{ source('raw_zoom', 'participants') }}
),

deduped_data AS (
    -- Apply deduplication logic to ensure unique records
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE row_num = 1
),

final_data AS (
    -- Final transformation with data quality checks
    SELECT 
        -- 1-1 mapping from RAW to Bronze layer
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE PARTICIPANT_ID IS NOT NULL -- Basic data quality check
)

SELECT * FROM final_data
