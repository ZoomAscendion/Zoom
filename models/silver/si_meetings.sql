{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Transform Bronze Meetings to Silver Meetings with enhanced data quality checks */
/* Includes Critical P1 fix for numeric field text unit cleaning ("108 mins" error) */

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
),

/* Critical P1 Fix: Clean numeric fields with text units */
clean_duration AS (
    SELECT 
        *,
        /* Clean duration text units (Critical P1 fix for "108 mins" error) */
        CASE 
            WHEN DURATION_MINUTES::STRING REGEXP '[^0-9.]' THEN 
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE DURATION_MINUTES
        END AS CLEAN_DURATION_MINUTES,
        
        /* Clean and convert EST timezone timestamps */
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS CLEAN_START_TIME,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS CLEAN_END_TIME
    FROM bronze_meetings
),

data_quality_checks AS (
    SELECT 
        *,
        /* Validate cleaned duration against calculated duration */
        CASE 
            WHEN CLEAN_START_TIME IS NOT NULL AND CLEAN_END_TIME IS NOT NULL THEN
                DATEDIFF('minute', CLEAN_START_TIME, CLEAN_END_TIME)
            ELSE NULL
        END AS CALCULATED_DURATION,
        
        /* Data Quality Score Calculation */
        (
            CASE WHEN MEETING_ID IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN HOST_ID IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN CLEAN_START_TIME IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN CLEAN_END_TIME IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN CLEAN_DURATION_MINUTES IS NOT NULL AND CLEAN_DURATION_MINUTES >= 0 AND CLEAN_DURATION_MINUTES <= 1440 THEN 20 ELSE 0 END +
            CASE WHEN CLEAN_END_TIME > CLEAN_START_TIME THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN (
                CASE WHEN MEETING_ID IS NOT NULL THEN 15 ELSE 0 END +
                CASE WHEN HOST_ID IS NOT NULL THEN 15 ELSE 0 END +
                CASE WHEN CLEAN_START_TIME IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_END_TIME IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_DURATION_MINUTES IS NOT NULL AND CLEAN_DURATION_MINUTES >= 0 AND CLEAN_DURATION_MINUTES <= 1440 THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_END_TIME > CLEAN_START_TIME THEN 10 ELSE 0 END
            ) >= 90 THEN 'PASSED'
            WHEN (
                CASE WHEN MEETING_ID IS NOT NULL THEN 15 ELSE 0 END +
                CASE WHEN HOST_ID IS NOT NULL THEN 15 ELSE 0 END +
                CASE WHEN CLEAN_START_TIME IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_END_TIME IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_DURATION_MINUTES IS NOT NULL AND CLEAN_DURATION_MINUTES >= 0 AND CLEAN_DURATION_MINUTES <= 1440 THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_END_TIME > CLEAN_START_TIME THEN 10 ELSE 0 END
            ) >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM clean_duration
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) as rn
    FROM data_quality_checks
)

SELECT 
    MEETING_ID,
    HOST_ID,
    COALESCE(TRIM(MEETING_TOPIC), 'UNTITLED_MEETING') AS MEETING_TOPIC,
    CLEAN_START_TIME AS START_TIME,
    CLEAN_END_TIME AS END_TIME,
    COALESCE(CLEAN_DURATION_MINUTES, 0) AS DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
  AND CLEAN_DURATION_MINUTES IS NOT NULL
