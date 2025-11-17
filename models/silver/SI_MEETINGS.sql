{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_START_TIME, EXECUTED_BY, LOAD_TIMESTAMP) SELECT 'SI_MEETINGS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT 'SI_MEETINGS', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Meetings Table
-- Purpose: Clean and standardized meeting information and session details
-- Transformation: Bronze BZ_MEETINGS -> Silver SI_MEETINGS

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
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
    WHERE MEETING_ID IS NOT NULL
),

timestamp_cleaning AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        -- Handle EST timezone format
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS START_TIME,
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS END_TIME,
        -- Clean duration text units (Critical P1 fix for "108 mins" error)
        CASE 
            WHEN DURATION_MINUTES::STRING REGEXP '[a-zA-Z]' THEN 
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_meetings
),

data_quality_checks AS (
    SELECT 
        *,
        -- Duration consistency check
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND DURATION_MINUTES IS NOT NULL THEN
                CASE 
                    WHEN ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) <= 1 THEN 1
                    ELSE 0
                END
            ELSE 0
        END AS duration_consistent,
        
        -- Time logic validation
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME > START_TIME THEN 1
            ELSE 0
        END AS time_logic_valid,
        
        -- Duration range check
        CASE 
            WHEN DURATION_MINUTES >= 0 AND DURATION_MINUTES <= 1440 THEN 1
            ELSE 0
        END AS duration_range_valid,
        
        -- Calculate data quality score
        CASE 
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL AND END_TIME IS NOT NULL THEN
                CASE 
                    WHEN END_TIME > START_TIME AND DURATION_MINUTES >= 0 AND DURATION_MINUTES <= 1440 
                         AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) <= 1 THEN 100
                    WHEN END_TIME > START_TIME AND DURATION_MINUTES >= 0 AND DURATION_MINUTES <= 1440 THEN 80
                    WHEN END_TIME > START_TIME THEN 60
                    ELSE 40
                END
            ELSE 0
        END AS data_quality_score
    FROM timestamp_cleaning
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

cleaned_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        COALESCE(TRIM(MEETING_TOPIC), 'Untitled Meeting') AS MEETING_TOPIC,
        START_TIME,
        END_TIME,
        -- Ensure duration is calculated correctly if missing or invalid
        CASE 
            WHEN DURATION_MINUTES IS NOT NULL AND DURATION_MINUTES >= 0 AND DURATION_MINUTES <= 1440 THEN DURATION_MINUTES
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME > START_TIME THEN 
                DATEDIFF('minute', START_TIME, END_TIME)
            ELSE 0
        END AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 80 THEN 'PASSED'
            WHEN data_quality_score >= 50 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
      AND MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND END_TIME > START_TIME
)

SELECT * FROM cleaned_meetings
