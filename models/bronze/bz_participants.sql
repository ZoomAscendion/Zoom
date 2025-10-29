-- Bronze Layer Participants Model
-- Transforms raw participant data from RAW.PARTICIPANTS to BRONZE.BZ_PARTICIPANTS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

SELECT 
    -- Business columns from source (1:1 mapping)
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
WHERE PARTICIPANT_ID IS NOT NULL
