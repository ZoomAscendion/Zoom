{{ config(materialized='table') }}

WITH source_data AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        m.MEETING_TOPIC,
        m.START_TIME,
        m.END_TIME,
        m.DURATION_MINUTES,
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        u.USER_NAME AS HOST_NAME
    FROM {{ ref('bz_meetings') }} m
    LEFT JOIN {{ ref('bz_users') }} u ON m.HOST_ID = u.USER_ID
    WHERE m.MEETING_ID IS NOT NULL
        AND m.HOST_ID IS NOT NULL
        AND m.START_TIME IS NOT NULL
),

cleaned_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        CASE 
            WHEN DURATION_MINUTES <= 30 THEN 'Instant'
            WHEN DURATION_MINUTES <= 60 THEN 'Scheduled'
            WHEN DURATION_MINUTES > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        START_TIME,
        CASE 
            WHEN END_TIME < START_TIME THEN DATEADD('minute', DURATION_MINUTES, START_TIME)
            ELSE END_TIME
        END AS END_TIME,
        CASE 
            WHEN DURATION_MINUTES < 0 THEN ABS(DURATION_MINUTES)
            WHEN DURATION_MINUTES IS NULL AND START_TIME IS NOT NULL AND END_TIME IS NOT NULL
            THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        COALESCE(HOST_NAME, 'Unknown Host') AS HOST_NAME,
        CASE 
            WHEN END_TIME IS NULL OR END_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            WHEN START_TIME <= CURRENT_TIMESTAMP() AND END_TIME > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN END_TIME <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Cancelled'
        END AS MEETING_STATUS,
        'No' AS RECORDING_STATUS,
        0 AS PARTICIPANT_COUNT,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        1.00 AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE START_TIME IS NOT NULL
        AND (END_TIME IS NULL OR END_TIME >= START_TIME)
),

with_participant_count AS (
    SELECT 
        c.*,
        COALESCE(p.participant_count, 0) AS calculated_participant_count
    FROM cleaned_data c
    LEFT JOIN (
        SELECT 
            MEETING_ID,
            COUNT(DISTINCT USER_ID) AS participant_count
        FROM {{ ref('bz_participants') }}
        GROUP BY MEETING_ID
    ) p ON c.MEETING_ID = p.MEETING_ID
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM with_participant_count
    QUALIFY row_num = 1
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
    calculated_participant_count AS PARTICIPANT_COUNT,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM deduplicated
