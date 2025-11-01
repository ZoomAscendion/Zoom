{{ config(
    materialized='table',
    tags=['silver', 'meetings']
) }}

WITH source_meetings AS (
    SELECT
        bm.MEETING_ID,
        bm.HOST_ID,
        bm.MEETING_TOPIC,
        bm.START_TIME,
        bm.END_TIME,
        bm.DURATION_MINUTES,
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        bm.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_meetings') }} bm
    WHERE bm.MEETING_ID IS NOT NULL
      AND bm.HOST_ID IS NOT NULL
      AND bm.START_TIME IS NOT NULL
      AND bm.END_TIME IS NOT NULL
      AND bm.END_TIME >= bm.START_TIME
),

validated_users AS (
    SELECT
        USER_ID,
        USER_NAME
    FROM {{ ref('si_users') }}
),

participant_counts AS (
    SELECT
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
    GROUP BY MEETING_ID
),

validated_meetings AS (
    SELECT
        sm.MEETING_ID,
        sm.HOST_ID,
        TRIM(sm.MEETING_TOPIC) AS MEETING_TOPIC,
        CASE
            WHEN sm.MEETING_TOPIC ILIKE '%webinar%' THEN 'Webinar'
            WHEN sm.DURATION_MINUTES <= 5 THEN 'Instant'
            WHEN sm.DURATION_MINUTES > 180 THEN 'Personal'
            ELSE 'Scheduled'
        END AS MEETING_TYPE,
        sm.START_TIME,
        sm.END_TIME,
        CASE
            WHEN sm.DURATION_MINUTES BETWEEN 1 AND 1440 THEN sm.DURATION_MINUTES
            ELSE DATEDIFF('minute', sm.START_TIME, sm.END_TIME)
        END AS DURATION_MINUTES,
        COALESCE(vu.USER_NAME, 'Unknown Host') AS HOST_NAME,
        CASE
            WHEN sm.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN sm.START_TIME <= CURRENT_TIMESTAMP() AND sm.END_TIME >= CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN sm.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        'No' AS RECORDING_STATUS,
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        sm.LOAD_TIMESTAMP,
        sm.UPDATE_TIMESTAMP,
        sm.SOURCE_SYSTEM
    FROM source_meetings sm
    LEFT JOIN validated_users vu ON sm.HOST_ID = vu.USER_ID
    LEFT JOIN participant_counts pc ON sm.MEETING_ID = pc.MEETING_ID
    WHERE vu.USER_ID IS NOT NULL
),

quality_scored_meetings AS (
    SELECT
        *,
        (
            CASE WHEN MEETING_TOPIC IS NOT NULL AND TRIM(MEETING_TOPIC) != '' THEN 0.15 ELSE 0 END +
            CASE WHEN MEETING_TYPE IN ('Scheduled', 'Instant', 'Webinar', 'Personal') THEN 0.15 ELSE 0 END +
            CASE WHEN START_TIME IS NOT NULL AND START_TIME <= CURRENT_TIMESTAMP() THEN 0.20 ELSE 0 END +
            CASE WHEN END_TIME >= START_TIME THEN 0.20 ELSE 0 END +
            CASE WHEN DURATION_MINUTES BETWEEN 1 AND 1440 THEN 0.15 ELSE 0 END +
            CASE WHEN HOST_NAME != 'Unknown Host' THEN 0.15 ELSE 0 END
        ) AS DATA_QUALITY_SCORE
    FROM validated_meetings
),

deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS row_num
    FROM quality_scored_meetings
)

SELECT
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    MEETING_TYPE,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    HOST_NAME,
    MEETING_STATUS,
    RECORDING_STATUS,
    PARTICIPANT_COUNT,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_meetings
WHERE row_num = 1
  AND DATA_QUALITY_SCORE >= 0.60
