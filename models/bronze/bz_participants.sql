-- Bronze Layer Participants Model
-- Transforms raw participant data from RAW.PARTICIPANTS to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_PARTICIP', CURRENT_TIMESTAMP(), 'DBT', 'STARTED')
    ",
    post_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS, RECORD_COUNT)
        VALUES ('BZ_PARTICIP', CURRENT_TIMESTAMP(), 'DBT', 1.0, 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}))
    "
) }}

-- CTE for raw data extraction
WITH raw_participants AS (
    SELECT 
        -- Business columns from source
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'participants') }}
),

-- CTE for data validation and cleansing
validated_participants AS (
    SELECT 
        -- Apply data quality checks and preserve original structure
        COALESCE(PARTICIPANT_ID, 'UNKNOWN') as PARTICIPANT_ID,
        COALESCE(MEETING_ID, 'UNKNOWN') as MEETING_ID,
        COALESCE(USER_ID, 'UNKNOWN') as USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Metadata preservation
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) as LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) as UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') as SOURCE_SYSTEM
        
    FROM raw_participants
)

-- Final selection for Bronze layer
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_participants
