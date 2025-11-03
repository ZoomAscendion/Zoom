{{ config(
    materialized='table'
) }}

-- Main transformation for SI_MEETINGS
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
),

cleaned_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        CASE 
            WHEN DURATION_MINUTES <= 30 THEN 'Instant'
            WHEN DURATION_MINUTES <= 120 THEN 'Scheduled'
            ELSE 'Webinar'
        END AS MEETING_TYPE,
        START_TIME,
        CASE 
            WHEN END_TIME < START_TIME THEN DATEADD('minute', DURATION_MINUTES, START_TIME)
            ELSE END_TIME
        END AS END_TIME,
        CASE 
            WHEN DURATION_MINUTES < 0 THEN ABS(DURATION_MINUTES)
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        TRIM(HOST_NAME) AS HOST_NAME,
        CASE 
            WHEN END_TIME IS NULL OR START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            WHEN START_TIME <= CURRENT_TIMESTAMP() AND (END_TIME IS NULL OR END_TIME > CURRENT_TIMESTAMP()) THEN 'In Progress'
            WHEN END_TIME <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Scheduled'
        END AS MEETING_STATUS,
        'No' AS RECORDING_STATUS,
        0 AS PARTICIPANT_COUNT,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        CASE 
            WHEN MEETING_TOPIC IS NOT NULL 
                 AND START_TIME IS NOT NULL 
                 AND END_TIME IS NOT NULL 
                 AND DURATION_MINUTES > 0
            THEN 1.00
            ELSE 0.80
        END AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE START_TIME IS NOT NULL
),

participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS participant_count
    FROM {{ ref('bz_participants') }}
    GROUP BY MEETING_ID
),

deduplicated AS (
    SELECT 
        c.*,
        COALESCE(p.participant_count, 0) AS final_participant_count,
        ROW_NUMBER() OVER (
            PARTITION BY c.MEETING_ID 
            ORDER BY c.UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data c
    LEFT JOIN participant_counts p ON c.MEETING_ID = p.MEETING_ID
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
    final_participant_count AS PARTICIPANT_COUNT,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM deduplicated
