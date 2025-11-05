{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Participants transformation with data quality checks
WITH bronze_participants AS (
    SELECT *
    FROM {{ ref('bz_participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
      AND TRIM(PARTICIPANT_ID) != ''
      AND MEETING_ID IS NOT NULL
      AND JOIN_TIME IS NOT NULL
      AND LEAVE_TIME IS NOT NULL
      AND JOIN_TIME <= LEAVE_TIME
),

valid_meetings AS (
    SELECT MEETING_ID, START_TIME, END_TIME
    FROM {{ ref('si_meetings') }}
),

valid_users AS (
    SELECT DISTINCT USER_ID
    FROM {{ ref('si_users') }}
),

filtered_participants AS (
    SELECT bp.*
    FROM bronze_participants bp
    INNER JOIN valid_meetings vm ON bp.MEETING_ID = vm.MEETING_ID
    LEFT JOIN valid_users vu ON bp.USER_ID = vu.USER_ID
    WHERE bp.JOIN_TIME >= vm.START_TIME
      AND bp.LEAVE_TIME <= vm.END_TIME
      AND (bp.USER_ID IS NULL OR vu.USER_ID IS NOT NULL)
),

deduped_participants AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM filtered_participants
),

final_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        CASE 
            WHEN LEAVE_TIME IS NOT NULL AND JOIN_TIME IS NOT NULL 
            THEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
            ELSE NULL
        END AS ATTENDANCE_DURATION,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM deduped_participants
    WHERE rn = 1
)

SELECT * FROM final_participants
