{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_PARTICIPANTS', 'PROCESSING_STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_PARTICIPANTS', 'PROCESSING_COMPLETED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- SI_PARTICIPANTS: Cleaned and standardized meeting participants and session details
-- Transformation from Bronze BZ_PARTICIPANTS to Silver SI_PARTICIPANTS
-- Includes MM/DD/YYYY timestamp format handling

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
    WHERE PARTICIPANT_ID IS NOT NULL
),

-- Handle MM/DD/YYYY HH:MM timestamp format conversion
cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Handle MM/DD/YYYY HH:MM format conversion
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            WHEN TYPEOF(JOIN_TIME) = 'VARCHAR' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME, 'DD/MM/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            WHEN TYPEOF(LEAVE_TIME) = 'VARCHAR' THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME, 'DD/MM/YYYY HH24:MI')
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
),

-- Data Quality Validation
validated_participants AS (
    SELECT 
        p.PARTICIPANT_ID,
        p.MEETING_ID,
        p.USER_ID,
        p.JOIN_TIME,
        p.LEAVE_TIME,
        p.LOAD_TIMESTAMP,
        p.UPDATE_TIMESTAMP,
        p.SOURCE_SYSTEM,
        -- Data Quality Scoring
        CASE 
            WHEN p.JOIN_TIME IS NOT NULL AND p.LEAVE_TIME IS NOT NULL 
                 AND p.LEAVE_TIME > p.JOIN_TIME
                 AND m.MEETING_ID IS NOT NULL
                 AND u.USER_ID IS NOT NULL
            THEN 100
            WHEN p.JOIN_TIME IS NOT NULL AND p.LEAVE_TIME IS NOT NULL AND p.LEAVE_TIME > p.JOIN_TIME
            THEN 80
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN p.JOIN_TIME IS NOT NULL AND p.LEAVE_TIME IS NOT NULL 
                 AND p.LEAVE_TIME > p.JOIN_TIME
                 AND m.MEETING_ID IS NOT NULL
                 AND u.USER_ID IS NOT NULL
            THEN 'PASSED'
            WHEN p.JOIN_TIME IS NULL OR p.LEAVE_TIME IS NULL OR p.LEAVE_TIME <= p.JOIN_TIME
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_participants p
    LEFT JOIN {{ ref('si_meetings') }} m ON p.MEETING_ID = m.MEETING_ID
    LEFT JOIN {{ ref('si_users') }} u ON p.USER_ID = u.USER_ID
),

-- Remove Duplicates (Keep latest record)
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
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
WHERE rn = 1
  AND JOIN_TIME IS NOT NULL
  AND LEAVE_TIME IS NOT NULL
  AND LEAVE_TIME > JOIN_TIME
