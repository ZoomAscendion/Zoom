-- Bronze Layer Meetings Model
-- Transforms raw meeting data from RAW.MEETINGS to BRONZE.BZ_MEETINGS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

SELECT 
    -- Business columns from source (1:1 mapping)
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    
    -- Metadata columns
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM {{ source('raw', 'meetings') }}
WHERE MEETING_ID IS NOT NULL
