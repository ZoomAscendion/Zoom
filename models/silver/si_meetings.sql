{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Bronze to Silver transformation for Meetings
-- Implements data quality checks and business rules

WITH bronze_meetings AS (
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
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
      AND TRIM(MEETING_ID) != ''
),

data_quality_checks AS (
    SELECT 
        *,
        -- Duration validation
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL
            THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE DURATION_MINUTES
        END AS calculated_duration,
        
        -- Chronological validation
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME <= START_TIME
            THEN 'INVALID_CHRONOLOGY'
            WHEN DURATION_MINUTES IS NOT NULL AND DURATION_MINUTES < 1
            THEN 'INVALID_DURATION'
            ELSE 'VALID'
        END AS validation_status
    FROM bronze_meetings
),

valid_records AS (
    SELECT 
        bm.MEETING_ID,
        bm.HOST_ID,
        TRIM(bm.MEETING_TOPIC) AS MEETING_TOPIC,
        bm.START_TIME,
        bm.END_TIME,
        bm.calculated_duration AS DURATION_MINUTES,
        DATE(bm.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bm.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        bm.SOURCE_SYSTEM,
        bm.LOAD_TIMESTAMP,
        bm.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY bm.MEETING_ID ORDER BY bm.UPDATE_TIMESTAMP DESC) AS rn
    FROM data_quality_checks bm
    INNER JOIN {{ ref('si_users') }} u ON bm.HOST_ID = u.USER_ID
    WHERE bm.validation_status = 'VALID'
      AND bm.START_TIME IS NOT NULL
      AND bm.END_TIME IS NOT NULL
      AND bm.calculated_duration >= 1
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
FROM valid_records
WHERE rn = 1
