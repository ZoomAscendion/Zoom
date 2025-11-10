{{ config(
    materialized='table'
) }}

-- Silver Layer Participants Table
-- Transforms and cleanses participant data from Bronze layer
-- Handles MM/DD/YYYY HH:MM timestamp format conversion

WITH bronze_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_participants') }}
),

-- Timestamp Format Validation and Conversion
timestamp_processed AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Handle MM/DD/YYYY HH:MM format conversion
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Track timestamp format issues
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
                 AND TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NULL THEN 'MMDDYYYY_FORMAT_ERROR'
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
                 AND TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NULL THEN 'MMDDYYYY_FORMAT_ERROR'
            ELSE 'FORMAT_OK'
        END AS TIMESTAMP_FORMAT_STATUS
    FROM bronze_participants
),

-- Data Quality and Business Logic Validation
cleansed_participants AS (
    SELECT 
        p.PARTICIPANT_ID,
        p.MEETING_ID,
        p.USER_ID,
        p.JOIN_TIME,
        p.LEAVE_TIME,
        p.LOAD_TIMESTAMP,
        p.UPDATE_TIMESTAMP,
        p.SOURCE_SYSTEM,
        p.TIMESTAMP_FORMAT_STATUS,
        
        -- Data Quality Scoring
        CASE 
            WHEN p.PARTICIPANT_ID IS NULL THEN 0
            WHEN p.MEETING_ID IS NULL THEN 20
            WHEN p.USER_ID IS NULL THEN 30
            WHEN p.JOIN_TIME IS NULL OR p.LEAVE_TIME IS NULL THEN 40
            WHEN p.TIMESTAMP_FORMAT_STATUS = 'MMDDYYYY_FORMAT_ERROR' THEN 50
            WHEN p.LEAVE_TIME <= p.JOIN_TIME THEN 60
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN p.PARTICIPANT_ID IS NULL OR p.MEETING_ID IS NULL OR p.USER_ID IS NULL THEN 'FAILED'
            WHEN p.JOIN_TIME IS NULL OR p.LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN p.TIMESTAMP_FORMAT_STATUS = 'MMDDYYYY_FORMAT_ERROR' THEN 'FAILED'
            WHEN p.LEAVE_TIME <= p.JOIN_TIME THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_processed p
),

-- Remove duplicates - keep latest record
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_participants
    WHERE PARTICIPANT_ID IS NOT NULL
      AND TIMESTAMP_FORMAT_STATUS != 'MMDDYYYY_FORMAT_ERROR'
)

-- Final Select with Silver layer metadata
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
