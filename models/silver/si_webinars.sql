{{ config(materialized='table') }}

WITH source_data AS (
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
    FROM {{ ref('bz_webinars') }}
    WHERE WEBINAR_ID IS NOT NULL
        AND HOST_ID IS NOT NULL
),

cleaned_data AS (
    SELECT 
        WEBINAR_ID,
        HOST_ID,
        COALESCE(NULLIF(TRIM(WEBINAR_TOPIC), ''), 'Unknown Topic') AS WEBINAR_TOPIC,
        START_TIME,
        CASE 
            WHEN END_TIME IS NULL THEN DATEADD('hour', 1, START_TIME)
            WHEN END_TIME < START_TIME THEN DATEADD('hour', 1, START_TIME)
            ELSE END_TIME
        END AS END_TIME,
        CASE 
            WHEN END_TIME IS NOT NULL AND END_TIME >= START_TIME 
            THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE 60
        END AS DURATION_MINUTES,
        CASE 
            WHEN REGISTRANTS < 0 THEN 0
            ELSE REGISTRANTS
        END AS REGISTRANTS,
        CASE 
            WHEN REGISTRANTS > 0 THEN ROUND(REGISTRANTS * 0.75)
            ELSE 0
        END AS ATTENDEES,
        CASE 
            WHEN REGISTRANTS > 0 THEN ROUND((REGISTRANTS * 0.75 / REGISTRANTS) * 100, 2)
            ELSE 0.00
        END AS ATTENDANCE_RATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        1.00 AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE START_TIME IS NOT NULL
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY WEBINAR_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
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
    LOAD_DATE,
    UPDATE_DATE
FROM deduplicated
