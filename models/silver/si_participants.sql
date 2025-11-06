{{ config(
    materialized='table'
) }}

-- Silver Layer Participants Table Transformation
-- Applies data quality checks, standardization, and business rules

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE LOAD_TIMESTAMP IS NOT NULL
),

validated_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality validation
        CASE 
            WHEN PARTICIPANT_ID IS NULL OR TRIM(PARTICIPANT_ID) = '' THEN 'INVALID_PARTICIPANT_ID'
            WHEN MEETING_ID IS NULL OR TRIM(MEETING_ID) = '' THEN 'INVALID_MEETING_ID'
            WHEN USER_ID IS NULL OR TRIM(USER_ID) = '' THEN 'INVALID_USER_ID'
            WHEN JOIN_TIME IS NULL THEN 'INVALID_JOIN_TIME'
            WHEN LEAVE_TIME IS NOT NULL AND JOIN_TIME >= LEAVE_TIME THEN 'INVALID_TIME_RANGE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM bronze_participants
),

cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        -- Calculate attendance duration
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
    FROM validated_participants
    WHERE data_quality_flag = 'VALID'
),

deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM cleansed_participants
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
FROM deduped_participants
WHERE row_num = 1
