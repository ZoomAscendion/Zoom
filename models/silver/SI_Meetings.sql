{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Layer Meetings Table Transformation */
/* Includes critical P1 fixes for numeric field text unit cleaning and EST timezone handling */

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
    FROM BRONZE.BZ_MEETINGS
    WHERE MEETING_ID IS NOT NULL
),

timestamp_cleaning AS (
    SELECT 
        *,
        /* Critical P1 Fix: EST timezone format handling */
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME)
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(START_TIME, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(START_TIME, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME)
                )
        END AS CLEAN_START_TIME,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME)
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(END_TIME, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(END_TIME, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME)
                )
        END AS CLEAN_END_TIME,
        
        /* Critical P1 Fix: Clean duration text units like "108 mins" */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(DURATION_MINUTES::STRING)
        END AS CLEAN_DURATION_MINUTES
    FROM bronze_meetings
),

data_quality_checks AS (
    SELECT 
        *,
        /* Calculate duration from cleaned timestamps for validation */
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
            CASE WHEN LOAD_TIMESTAMP IS NOT NULL THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL OR CLEAN_START_TIME IS NULL OR CLEAN_END_TIME IS NULL THEN 'FAILED'
            WHEN CLEAN_END_TIME <= CLEAN_START_TIME THEN 'FAILED'
            WHEN CLEAN_DURATION_MINUTES IS NULL OR CLEAN_DURATION_MINUTES < 0 OR CLEAN_DURATION_MINUTES > 1440 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_cleaning
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_checks
)

SELECT 
    MEETING_ID,
    HOST_ID,
    TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
    CLEAN_START_TIME AS START_TIME,
    CLEAN_END_TIME AS END_TIME,
    CLEAN_DURATION_MINUTES AS DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
  AND CLEAN_START_TIME IS NOT NULL
  AND CLEAN_END_TIME IS NOT NULL
  AND CLEAN_DURATION_MINUTES IS NOT NULL
