{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Bronze to Silver transformation for Participants
-- Implements data quality checks and calculated fields

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
      AND TRIM(PARTICIPANT_ID) != ''
),

data_quality_checks AS (
    SELECT 
        bp.*,
        m.START_TIME AS meeting_start,
        m.END_TIME AS meeting_end,
        m.DURATION_MINUTES AS meeting_duration,
        -- Calculate attendance duration
        CASE 
            WHEN bp.JOIN_TIME IS NOT NULL AND bp.LEAVE_TIME IS NOT NULL
            THEN DATEDIFF('minute', bp.JOIN_TIME, bp.LEAVE_TIME)
            ELSE NULL
        END AS calculated_attendance_duration,
        
        -- Validation checks
        CASE 
            WHEN bp.JOIN_TIME IS NULL THEN 'MISSING_JOIN_TIME'
            WHEN bp.LEAVE_TIME IS NOT NULL AND bp.LEAVE_TIME < bp.JOIN_TIME THEN 'INVALID_CHRONOLOGY'
            WHEN bp.JOIN_TIME < m.START_TIME THEN 'JOIN_BEFORE_MEETING'
            WHEN bp.LEAVE_TIME > m.END_TIME THEN 'LEAVE_AFTER_MEETING'
            ELSE 'VALID'
        END AS validation_status
    FROM bronze_participants bp
    INNER JOIN {{ ref('si_meetings') }} m ON bp.MEETING_ID = m.MEETING_ID
),

valid_records AS (
    SELECT 
        dqc.PARTICIPANT_ID,
        dqc.MEETING_ID,
        dqc.USER_ID,
        dqc.JOIN_TIME,
        dqc.LEAVE_TIME,
        GREATEST(dqc.calculated_attendance_duration, 0) AS ATTENDANCE_DURATION,
        DATE(dqc.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(dqc.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        dqc.SOURCE_SYSTEM,
        dqc.LOAD_TIMESTAMP,
        dqc.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY dqc.PARTICIPANT_ID ORDER BY dqc.UPDATE_TIMESTAMP DESC) AS rn
    FROM data_quality_checks dqc
    INNER JOIN {{ ref('si_users') }} u ON dqc.USER_ID = u.USER_ID
    WHERE dqc.validation_status = 'VALID'
      AND dqc.JOIN_TIME IS NOT NULL
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    ATTENDANCE_DURATION,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM valid_records
WHERE rn = 1
