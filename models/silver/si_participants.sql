{{ config(materialized='table') }}

WITH source_data AS (
    SELECT 
        p.PARTICIPANT_ID,
        p.MEETING_ID,
        p.USER_ID,
        p.JOIN_TIME,
        p.LEAVE_TIME,
        p.LOAD_TIMESTAMP,
        p.UPDATE_TIMESTAMP,
        p.SOURCE_SYSTEM,
        m.HOST_ID
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_meetings') }} m ON p.MEETING_ID = m.MEETING_ID
    WHERE p.PARTICIPANT_ID IS NOT NULL
        AND p.MEETING_ID IS NOT NULL
        AND p.USER_ID IS NOT NULL
        AND p.JOIN_TIME IS NOT NULL
),

cleaned_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        CASE 
            WHEN LEAVE_TIME IS NULL THEN DATEADD('minute', 30, JOIN_TIME)
            WHEN LEAVE_TIME < JOIN_TIME THEN JOIN_TIME
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        CASE 
            WHEN LEAVE_TIME IS NOT NULL AND LEAVE_TIME >= JOIN_TIME 
            THEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
            ELSE 30
        END AS ATTENDANCE_DURATION,
        CASE 
            WHEN USER_ID = HOST_ID THEN 'Host'
            ELSE 'Participant'
        END AS PARTICIPANT_ROLE,
        CASE 
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 30, JOIN_TIME))) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 30, JOIN_TIME))) >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        1.00 AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE JOIN_TIME <= CURRENT_TIMESTAMP()
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
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
    LOAD_DATE,
    UPDATE_DATE
FROM deduplicated
