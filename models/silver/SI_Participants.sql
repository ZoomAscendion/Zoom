{{ config(
    materialized='table'
) }}

-- Silver Layer Participants Table
-- Cleansed and standardized meeting participants with MM/DD/YYYY format handling

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
        
        /* MM/DD/YYYY HH:MM format handling */
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME)
        ) AS JOIN_TIME,
        
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME)
        ) AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
),

validated_participants AS (
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
        
        /* Data quality score calculation */
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
        
        /* Validation status */
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND JOIN_TIME IS NOT NULL 
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME > JOIN_TIME
            THEN 'PASSED'
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_participants
),

/* Remove duplicates - keep latest record */
deduped_participants AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
        FROM validated_participants
    ) ranked
    WHERE rn = 1
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
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
