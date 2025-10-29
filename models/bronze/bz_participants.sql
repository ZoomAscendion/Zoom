-- Bronze Layer Participants Model
-- Transforms raw participant data from RAW.PARTICIPANTS to BRONZE.BZ_PARTICIPANTS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table'
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
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
        SOURCE_SYSTEM,
        
        -- Data quality flags
        CASE 
            WHEN PARTICIPANT_ID IS NULL THEN 'MISSING_PARTICIPANT_ID'
            WHEN MEETING_ID IS NULL THEN 'MISSING_MEETING_ID'
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'participants') }}
),

-- CTE for final data selection
final_data AS (
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
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_data
