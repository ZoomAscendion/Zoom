{{ config(
    materialized='table',
    tags=['silver', 'participants']
) }}

WITH source_participants AS (
    SELECT
        bp.PARTICIPANT_ID,
        bp.MEETING_ID,
        bp.USER_ID,
        bp.JOIN_TIME,
        bp.LEAVE_TIME,
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        bp.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_participants') }} bp
    WHERE bp.PARTICIPANT_ID IS NOT NULL
      AND bp.MEETING_ID IS NOT NULL
      AND bp.USER_ID IS NOT NULL
      AND bp.JOIN_TIME IS NOT NULL
),

validated_meetings AS (
    SELECT MEETING_ID, DURATION_MINUTES
    FROM {{ ref('si_meetings') }}
),

validated_users AS (
    SELECT USER_ID
    FROM {{ ref('si_users') }}
),

validated_participants AS (
    SELECT
        sp.PARTICIPANT_ID,
        sp.MEETING_ID,
        sp.USER_ID,
        sp.JOIN_TIME,
        sp.LEAVE_TIME,
        CASE
            WHEN sp.LEAVE_TIME IS NOT NULL AND sp.LEAVE_TIME >= sp.JOIN_TIME
            THEN DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)
            ELSE 0
        END AS ATTENDANCE_DURATION,
        'Participant' AS PARTICIPANT_ROLE,
        'Good' AS CONNECTION_QUALITY,
        sp.LOAD_TIMESTAMP,
        sp.UPDATE_TIMESTAMP,
        sp.SOURCE_SYSTEM
    FROM source_participants sp
    INNER JOIN validated_meetings vm ON sp.MEETING_ID = vm.MEETING_ID
    INNER JOIN validated_users vu ON sp.USER_ID = vu.USER_ID
    WHERE (sp.LEAVE_TIME IS NULL OR sp.LEAVE_TIME >= sp.JOIN_TIME)
),

quality_scored_participants AS (
    SELECT
        *,
        (
            CASE WHEN JOIN_TIME IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN LEAVE_TIME IS NULL OR LEAVE_TIME >= JOIN_TIME THEN 0.25 ELSE 0 END +
            CASE WHEN ATTENDANCE_DURATION >= 0 THEN 0.25 ELSE 0 END +
            CASE WHEN PARTICIPANT_ROLE IN ('Host', 'Co-host', 'Participant', 'Observer') THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE
    FROM validated_participants
),

deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS row_num
    FROM quality_scored_participants
)

SELECT
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    ATTENDANCE_DURATION,
    PARTICIPANT_ROLE,
    CONNECTION_QUALITY,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_participants
WHERE row_num = 1
  AND DATA_QUALITY_SCORE >= 0.60
