-- models/silver/si_meetings.sql
{{ config(
    materialized='table'
) }}

-- Main transformation using CTEs
WITH source_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM DB_POC_ZOOM.BRONZE.BZ_MEETINGS
    WHERE MEETING_ID IS NOT NULL
),

user_data AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM DB_POC_ZOOM.BRONZE.BZ_USERS
    WHERE USER_ID IS NOT NULL
),

participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM DB_POC_ZOOM.BRONZE.BZ_PARTICIPANTS
    WHERE MEETING_ID IS NOT NULL
    GROUP BY MEETING_ID
),

cleaned_data AS (
    -- Data quality checks and transformations
    SELECT 
        s.MEETING_ID,
        s.HOST_ID,
        TRIM(COALESCE(s.MEETING_TOPIC, 'Unknown Topic')) AS MEETING_TOPIC,
        CASE 
            WHEN s.DURATION_MINUTES <= 40 THEN 'Instant'
            WHEN s.DURATION_MINUTES > 40 AND s.DURATION_MINUTES <= 480 THEN 'Scheduled'
            ELSE 'Webinar'
        END AS MEETING_TYPE,
        s.START_TIME,
        COALESCE(s.END_TIME, DATEADD('minute', COALESCE(s.DURATION_MINUTES, 60), s.START_TIME)) AS END_TIME,
        COALESCE(s.DURATION_MINUTES, DATEDIFF('minute', s.START_TIME, s.END_TIME)) AS DURATION_MINUTES,
        COALESCE(u.USER_NAME, 'Unknown Host') AS HOST_NAME,
        CASE 
            WHEN s.END_TIME IS NOT NULL AND s.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN s.START_TIME <= CURRENT_TIMESTAMP() AND (s.END_TIME IS NULL OR s.END_TIME > CURRENT_TIMESTAMP()) THEN 'In Progress'
            WHEN s.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Unknown'
        END AS MEETING_STATUS,
        CASE 
            WHEN s.DURATION_MINUTES > 60 OR COALESCE(p.PARTICIPANT_COUNT, 0) > 10 THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        COALESCE(p.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        s.LOAD_TIMESTAMP,
        s.UPDATE_TIMESTAMP,
        s.SOURCE_SYSTEM,
        -- Data quality score calculation
        CASE 
            WHEN s.MEETING_ID IS NOT NULL 
                AND s.HOST_ID IS NOT NULL 
                AND s.START_TIME IS NOT NULL
                AND s.DURATION_MINUTES > 0
            THEN 1.0
            WHEN s.MEETING_ID IS NOT NULL AND s.HOST_ID IS NOT NULL
            THEN 0.8
            WHEN s.MEETING_ID IS NOT NULL
            THEN 0.6
            ELSE 0.0
        END AS DATA_QUALITY_SCORE,
        DATE(s.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(s.UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data s
    LEFT JOIN user_data u ON s.HOST_ID = u.USER_ID
    LEFT JOIN participant_counts p ON s.MEETING_ID = p.MEETING_ID
    WHERE s.START_TIME IS NOT NULL
        AND s.DURATION_MINUTES IS NOT NULL
        AND s.DURATION_MINUTES > 0
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    LOAD_DATE,
    UPDATE_DATE
FROM deduplication
