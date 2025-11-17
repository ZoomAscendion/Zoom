{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Participants Table
-- Transforms and cleanses participant data from Bronze layer
-- Handles MM/DD/YYYY HH:MM format conversion and data quality checks

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
    FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
),

timestamp_converted AS (
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
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_participants
    WHERE PARTICIPANT_ID IS NOT NULL
),

validated_participants AS (
    SELECT 
        p.*,
        -- Calculate data quality score
        CASE 
            WHEN p.PARTICIPANT_ID IS NOT NULL 
                AND p.MEETING_ID IS NOT NULL 
                AND p.USER_ID IS NOT NULL 
                AND p.JOIN_TIME IS NOT NULL 
                AND p.LEAVE_TIME IS NOT NULL 
                AND p.LEAVE_TIME > p.JOIN_TIME
            THEN 100
            WHEN p.PARTICIPANT_ID IS NOT NULL AND p.MEETING_ID IS NOT NULL AND p.USER_ID IS NOT NULL 
            THEN 75
            WHEN p.PARTICIPANT_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Set validation status
        CASE 
            WHEN p.PARTICIPANT_ID IS NOT NULL 
                AND p.MEETING_ID IS NOT NULL 
                AND p.USER_ID IS NOT NULL 
                AND p.JOIN_TIME IS NOT NULL 
                AND p.LEAVE_TIME IS NOT NULL 
                AND p.LEAVE_TIME > p.JOIN_TIME
            THEN 'PASSED'
            WHEN p.PARTICIPANT_ID IS NOT NULL AND p.MEETING_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM timestamp_converted p
),

-- Remove duplicates keeping the latest record
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_participants
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
WHERE rn = 1
    AND VALIDATION_STATUS != 'FAILED'
    AND JOIN_TIME IS NOT NULL
    AND LEAVE_TIME IS NOT NULL
