-- =====================================================
-- BRONZE LAYER - PARTICIPANTS TABLE
-- Purpose: Raw to Bronze transformation for participant data
-- Source: RAW.PARTICIPANTS
-- Target: BRONZE.BZ_PARTICIPANTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    -- Extract raw data from source table
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
    FROM {{ source('raw', 'participants') }}
),

deduped_data AS (
    -- Apply deduplication logic
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
        AND PARTICIPANT_ID IS NOT NULL  -- Data quality check
        AND MEETING_ID IS NOT NULL
        AND USER_ID IS NOT NULL
),

final_data AS (
    -- Final transformation with audit columns
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final_data
