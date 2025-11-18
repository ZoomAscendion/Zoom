{{ config(
    materialized='table'
) }}

-- SI_Participants table transformation from Bronze to Silver
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
    FROM BRONZE.BZ_PARTICIPANTS
),

cleaned_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        /* Handle MM/DD/YYYY HH:MM format conversion for JOIN_TIME */
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING)
        ) AS JOIN_TIME,
        /* Handle MM/DD/YYYY HH:MM format conversion for LEAVE_TIME */
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING)
        ) AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
    WHERE PARTICIPANT_ID IS NOT NULL
),

validated_participants AS (
    SELECT 
        *,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        /* Calculate data quality score */
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND JOIN_TIME IS NOT NULL 
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME > JOIN_TIME
            THEN 100
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        /* Set validation status */
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND JOIN_TIME IS NOT NULL 
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME > JOIN_TIME
            THEN 'PASSED'
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_participants
),

/* Remove duplicates keeping the latest record */
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
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
