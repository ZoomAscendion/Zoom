{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- SI_MEETINGS: Silver layer transformation from Bronze BZ_MEETINGS
-- Includes critical P1 fixes for numeric field text unit cleaning and EST timezone handling

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
),

timestamp_cleaning AS (
    SELECT 
        *,
        -- Clean EST timezone from timestamps
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING)
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING)
                )
        END AS CLEAN_START_TIME,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING)
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING)
                )
        END AS CLEAN_END_TIME,
        
        -- Critical P1: Clean duration text units (fixes "108 mins" error)
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
        -- Data Quality Score Calculation
        CASE 
            WHEN MEETING_ID IS NULL THEN 0
            WHEN HOST_ID IS NULL THEN 20
            WHEN CLEAN_START_TIME IS NULL OR CLEAN_END_TIME IS NULL THEN 30
            WHEN CLEAN_DURATION_MINUTES IS NULL THEN 40
            WHEN CLEAN_END_TIME <= CLEAN_START_TIME THEN 50
            WHEN CLEAN_DURATION_MINUTES < 0 OR CLEAN_DURATION_MINUTES > 1440 THEN 60
            WHEN ABS(CLEAN_DURATION_MINUTES - DATEDIFF('minute', CLEAN_START_TIME, CLEAN_END_TIME)) > 1 THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL THEN 'FAILED'
            WHEN CLEAN_START_TIME IS NULL OR CLEAN_END_TIME IS NULL THEN 'FAILED'
            WHEN CLEAN_DURATION_MINUTES IS NULL THEN 'FAILED'
            WHEN CLEAN_END_TIME <= CLEAN_START_TIME THEN 'FAILED'
            WHEN CLEAN_DURATION_MINUTES < 0 OR CLEAN_DURATION_MINUTES > 1440 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_cleaning
),

cleaned_data AS (
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
    FROM data_quality_checks
    WHERE MEETING_ID IS NOT NULL  -- Eliminate null records
      AND CLEAN_START_TIME IS NOT NULL
      AND CLEAN_END_TIME IS NOT NULL
      AND CLEAN_DURATION_MINUTES IS NOT NULL
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM cleaned_data
)

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
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1  -- Eliminate duplicates
