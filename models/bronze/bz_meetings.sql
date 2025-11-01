-- Bronze Layer Meetings Model
-- Author: DBT Pipeline Generator
-- Description: Transform raw meetings data to bronze layer with audit information
-- Source: RAW.MEETINGS
-- Target: BRONZE.BZ_MEETINGS

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
            'BZ_MEETINGS', 
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
            'BZ_MEETINGS', 
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
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        
        -- Metadata columns from source
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_schema', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL  -- Basic data quality check
),

-- CTE for data quality validation
validated_data AS (
    SELECT 
        *,
        -- Add row validation flags
        CASE 
            WHEN MEETING_ID IS NULL THEN 'INVALID_MEETING_ID'
            WHEN HOST_ID IS NULL THEN 'INVALID_HOST_ID'
            WHEN START_TIME IS NULL THEN 'INVALID_START_TIME'
            ELSE 'VALID'
        END AS data_quality_status
    FROM source_data
)

-- Final SELECT with error handling
SELECT 
    -- Business columns (direct 1:1 mapping)
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    
    -- Metadata columns (direct 1:1 mapping)
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM validated_data
WHERE data_quality_status = 'VALID'
