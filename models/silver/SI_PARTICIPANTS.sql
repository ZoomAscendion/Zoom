{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Participants table
-- Applies data quality checks, referential integrity, and time boundary validation

WITH bronze_participants AS (
    SELECT 
        bp.PARTICIPANT_ID,
        bp.MEETING_ID,
        bp.USER_ID,
        -- Handle timestamp conversion - check if already timestamp or string
        CASE 
            WHEN TRY_TO_TIMESTAMP(bp.JOIN_TIME) IS NOT NULL THEN TRY_TO_TIMESTAMP(bp.JOIN_TIME)
            ELSE bp.JOIN_TIME
        END AS JOIN_TIME,
        CASE 
            WHEN TRY_TO_TIMESTAMP(bp.LEAVE_TIME) IS NOT NULL THEN TRY_TO_TIMESTAMP(bp.LEAVE_TIME)
            ELSE bp.LEAVE_TIME
        END AS LEAVE_TIME,
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        bp.SOURCE_SYSTEM
    FROM BRONZE.BZ_PARTICIPANTS bp
),

-- Data quality validation and cleansing (without cross-table joins for now)
cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality scoring
        CASE 
            WHEN PARTICIPANT_ID IS NULL THEN 0
            WHEN MEETING_ID IS NULL THEN 20
            WHEN USER_ID IS NULL THEN 30
            WHEN JOIN_TIME IS NULL OR LEAVE_TIME IS NULL THEN 40
            WHEN LEAVE_TIME <= JOIN_TIME THEN 50
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN JOIN_TIME IS NULL OR LEAVE_TIME IS NULL OR LEAVE_TIME <= JOIN_TIME THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_participants
),

-- Remove duplicates using ROW_NUMBER
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_participants
    WHERE PARTICIPANT_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND JOIN_TIME IS NOT NULL
      AND LEAVE_TIME IS NOT NULL
      AND LEAVE_TIME > JOIN_TIME
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
