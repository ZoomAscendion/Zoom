{{ config(
    materialized='table'
) }}

-- Silver Layer Meetings Table Transformation
-- Applies data quality checks, standardization, and business rules

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE LOAD_TIMESTAMP IS NOT NULL
),

validated_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality validation
        CASE 
            WHEN MEETING_ID IS NULL OR TRIM(MEETING_ID) = '' THEN 'INVALID_MEETING_ID'
            WHEN HOST_ID IS NULL OR TRIM(HOST_ID) = '' THEN 'INVALID_HOST_ID'
            WHEN START_TIME IS NULL THEN 'INVALID_START_TIME'
            WHEN END_TIME IS NULL THEN 'INVALID_END_TIME'
            WHEN START_TIME >= END_TIME THEN 'INVALID_TIME_RANGE'
            WHEN DURATION_MINUTES IS NULL OR DURATION_MINUTES <= 0 THEN 'INVALID_DURATION'
            WHEN START_TIME > CURRENT_TIMESTAMP() THEN 'FUTURE_MEETING'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM bronze_meetings
),

cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_meetings
    WHERE data_quality_flag = 'VALID'
),

deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM cleansed_meetings
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_meetings
WHERE row_num = 1
