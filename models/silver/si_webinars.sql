{{ config(
    materialized='table',
    tags=['silver', 'webinars']
) }}

WITH source_webinars AS (
    SELECT
        WEBINAR_ID,
        HOST_ID,
        WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        REGISTRANTS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_webinars') }}
    WHERE WEBINAR_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND END_TIME >= START_TIME
),

validated_users AS (
    SELECT USER_ID
    FROM {{ ref('si_users') }}
),

validated_webinars AS (
    SELECT
        sw.WEBINAR_ID,
        sw.HOST_ID,
        TRIM(sw.WEBINAR_TOPIC) AS WEBINAR_TOPIC,
        sw.START_TIME,
        sw.END_TIME,
        DATEDIFF('minute', sw.START_TIME, sw.END_TIME) AS DURATION_MINUTES,
        sw.REGISTRANTS,
        CASE
            WHEN sw.REGISTRANTS > 0 THEN FLOOR(sw.REGISTRANTS * 0.75)
            ELSE 0
        END AS ATTENDEES,
        CASE
            WHEN sw.REGISTRANTS > 0 THEN ROUND((FLOOR(sw.REGISTRANTS * 0.75)::FLOAT / sw.REGISTRANTS * 100), 2)
            ELSE 0
        END AS ATTENDANCE_RATE,
        sw.LOAD_TIMESTAMP,
        sw.UPDATE_TIMESTAMP,
        sw.SOURCE_SYSTEM
    FROM source_webinars sw
    INNER JOIN validated_users vu ON sw.HOST_ID = vu.USER_ID
),

quality_scored_webinars AS (
    SELECT
        *,
        (
            CASE WHEN WEBINAR_TOPIC IS NOT NULL AND TRIM(WEBINAR_TOPIC) != '' THEN 0.20 ELSE 0 END +
            CASE WHEN START_TIME IS NOT NULL AND START_TIME <= CURRENT_TIMESTAMP() THEN 0.20 ELSE 0 END +
            CASE WHEN END_TIME >= START_TIME THEN 0.20 ELSE 0 END +
            CASE WHEN DURATION_MINUTES > 0 THEN 0.20 ELSE 0 END +
            CASE WHEN REGISTRANTS >= 0 AND ATTENDEES <= REGISTRANTS THEN 0.20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE
    FROM validated_webinars
),

deduped_webinars AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY WEBINAR_ID ORDER BY UPDATE_TIMESTAMP DESC) AS row_num
    FROM quality_scored_webinars
)

SELECT
    WEBINAR_ID,
    HOST_ID,
    WEBINAR_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    REGISTRANTS,
    ATTENDEES,
    ATTENDANCE_RATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_webinars
WHERE row_num = 1
  AND DATA_QUALITY_SCORE >= 0.60
