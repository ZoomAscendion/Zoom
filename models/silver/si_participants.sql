{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Transform Bronze Participants to Silver Participants with timestamp format validation */

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
    WHERE PARTICIPANT_ID IS NOT NULL
),

/* Enhanced timestamp format handling */
clean_timestamps AS (
    SELECT 
        *,
        /* Multi-format timestamp parsing for JOIN_TIME */
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(JOIN_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS')
        ) AS CLEAN_JOIN_TIME,
        
        /* Multi-format timestamp parsing for LEAVE_TIME */
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(LEAVE_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS')
        ) AS CLEAN_LEAVE_TIME
    FROM bronze_participants
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        (
            CASE WHEN PARTICIPANT_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN CLEAN_JOIN_TIME IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN CLEAN_LEAVE_TIME IS NOT NULL THEN 10 ELSE 0 END +
            CASE WHEN CLEAN_LEAVE_TIME > CLEAN_JOIN_TIME THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN (
                CASE WHEN PARTICIPANT_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN MEETING_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_JOIN_TIME IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_LEAVE_TIME IS NOT NULL THEN 10 ELSE 0 END +
                CASE WHEN CLEAN_LEAVE_TIME > CLEAN_JOIN_TIME THEN 10 ELSE 0 END
            ) >= 90 THEN 'PASSED'
            WHEN (
                CASE WHEN PARTICIPANT_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN MEETING_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_JOIN_TIME IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_LEAVE_TIME IS NOT NULL THEN 10 ELSE 0 END +
                CASE WHEN CLEAN_LEAVE_TIME > CLEAN_JOIN_TIME THEN 10 ELSE 0 END
            ) >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM clean_timestamps
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) as rn
    FROM data_quality_checks
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    CLEAN_JOIN_TIME AS JOIN_TIME,
    COALESCE(CLEAN_LEAVE_TIME, DATEADD('minute', 60, CLEAN_JOIN_TIME)) AS LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
  AND CLEAN_JOIN_TIME IS NOT NULL
