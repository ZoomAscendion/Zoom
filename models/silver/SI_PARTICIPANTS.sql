{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Participants table
-- Applies data quality checks and MM/DD/YYYY timestamp format handling

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
    FROM BRONZE.BZ_PARTICIPANTS
    WHERE PARTICIPANT_ID IS NOT NULL
),

-- Data quality validation and cleansing with timestamp format handling
cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Handle MM/DD/YYYY HH:MM format
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
        -- Data quality scoring
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND JOIN_TIME IS NOT NULL 
                AND LEAVE_TIME IS NOT NULL
            THEN 100
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL
            THEN 75
            WHEN PARTICIPANT_ID IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        -- Validation status
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 'PASSED'
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_participants
),

-- Remove duplicates and failed records
deduped_participants AS (
    SELECT *
    FROM cleansed_participants
    WHERE rn = 1
      AND VALIDATION_STATUS != 'FAILED'
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
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
