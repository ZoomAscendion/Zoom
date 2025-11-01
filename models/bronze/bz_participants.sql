-- Bronze Layer Participants Model
-- Author: DBT Pipeline Generator
-- Description: Transform raw participants data to bronze layer with audit information
-- Source: RAW.PARTICIPANTS
-- Target: BRONZE.BZ_PARTICIPANTS

{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_START_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        VALUES (
            'BZ_PARTICIPANTS', 
            CURRENT_TIMESTAMP(), 
            'STARTED', 
            'DBT_PIPELINE'
        )
    ",
    post_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_END_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        VALUES (
            'BZ_PARTICIPANTS', 
            CURRENT_TIMESTAMP(), 
            'COMPLETED', 
            'DBT_PIPELINE'
        )
    "
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
        
        -- Metadata columns from source
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_schema', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL  -- Basic data quality check
),

-- CTE for data quality validation
validated_data AS (
    SELECT 
        *,
        -- Add row validation flags
        CASE 
            WHEN PARTICIPANT_ID IS NULL THEN 'INVALID_PARTICIPANT_ID'
            WHEN MEETING_ID IS NULL THEN 'INVALID_MEETING_ID'
            WHEN USER_ID IS NULL THEN 'INVALID_USER_ID'
            ELSE 'VALID'
        END AS data_quality_status
    FROM source_data
)

-- Final SELECT with error handling
SELECT 
    -- Business columns (direct 1:1 mapping)
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    
    -- Metadata columns (direct 1:1 mapping)
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM validated_data
WHERE data_quality_status = 'VALID'
