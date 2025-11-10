-- Bronze Layer Meetings Table
-- Description: Stores meeting information and session details
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}
-- Source: RAW.MEETINGS -> BRONZE.BZ_MEETINGS

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_MEETINGS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Unique identifier for each meeting
        MEETING_ID,
        
        -- User ID of the meeting host
        HOST_ID,
        
        -- Topic or title of the meeting
        MEETING_TOPIC,
        
        -- Meeting start timestamp
        START_TIME,
        
        -- Meeting end timestamp
        END_TIME,
        
        -- Meeting duration in minutes
        DURATION_MINUTES,
        
        -- Timestamp when record was loaded into system
        LOAD_TIMESTAMP,
        
        -- Timestamp when record was last updated
        UPDATE_TIMESTAMP,
        
        -- Source system from which data originated
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'meetings') }}
),

-- Data validation and cleansing
validated_data AS (
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
    FROM source_data
    -- Basic data quality checks
    WHERE MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
)

-- Final selection for Bronze layer
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
FROM validated_data
