{{ config(
    materialized='table'
) }}

/*
 * SI_PARTICIPANTS - Silver Layer Participants Table
 * Handles MM/DD/YYYY HH:MM timestamp format validation and conversion
 */

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

cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        /* Universal Timestamp Format Handling */
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING),
            JOIN_TIME
        ) AS JOIN_TIME,
        
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING),
            LEAVE_TIME
        ) AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE
    FROM bronze_participants
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
    
    /* Data Quality Score Calculation */
    CASE 
        WHEN PARTICIPANT_ID IS NOT NULL 
            AND MEETING_ID IS NOT NULL 
            AND USER_ID IS NOT NULL 
            AND JOIN_TIME IS NOT NULL 
            AND LEAVE_TIME IS NOT NULL 
        THEN 100
        WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL 
        THEN 75
        WHEN PARTICIPANT_ID IS NOT NULL 
        THEN 50
        ELSE 25
    END AS DATA_QUALITY_SCORE,
    
    /* Validation Status */
    CASE 
        WHEN PARTICIPANT_ID IS NOT NULL 
            AND MEETING_ID IS NOT NULL 
            AND USER_ID IS NOT NULL 
            AND JOIN_TIME IS NOT NULL 
            AND LEAVE_TIME IS NOT NULL 
        THEN 'PASSED'
        WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL 
        THEN 'WARNING'
        ELSE 'FAILED'
    END AS VALIDATION_STATUS
FROM cleansed_participants
