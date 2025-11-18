{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'"
) }}

-- Silver layer transformation for Meetings table with enhanced data quality checks
WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
),

timestamp_cleaning AS (
    SELECT 
        *,
        -- Clean EST timezone from timestamps
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS cleaned_start_time,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS cleaned_end_time,
        
        -- Critical P1: Clean numeric field text units from DURATION_MINUTES
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(DURATION_MINUTES::STRING)
        END AS cleaned_duration_minutes
    FROM bronze_meetings
),

data_quality_checks AS (
    SELECT 
        *,
        -- Validate meeting logic
        CASE 
            WHEN cleaned_end_time <= cleaned_start_time THEN 'INVALID_TIME_LOGIC'
            WHEN cleaned_duration_minutes < 0 OR cleaned_duration_minutes > 1440 THEN 'INVALID_DURATION_RANGE'
            WHEN ABS(cleaned_duration_minutes - DATEDIFF('minute', cleaned_start_time, cleaned_end_time)) > 1 THEN 'DURATION_MISMATCH'
            ELSE 'VALID'
        END AS time_validation,
        
        -- Data quality score calculation
        (
            CASE WHEN MEETING_ID IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN HOST_ID IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN cleaned_start_time IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN cleaned_end_time IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN cleaned_duration_minutes IS NOT NULL AND cleaned_duration_minutes >= 0 THEN 15 ELSE 0 END +
            CASE WHEN cleaned_end_time > cleaned_start_time THEN 15 ELSE 0 END
        ) AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL OR cleaned_start_time IS NULL OR cleaned_end_time IS NULL THEN 'FAILED'
            WHEN cleaned_end_time <= cleaned_start_time OR cleaned_duration_minutes IS NULL THEN 'FAILED'
            WHEN ABS(cleaned_duration_minutes - DATEDIFF('minute', cleaned_start_time, cleaned_end_time)) > 1 THEN 'WARNING'
            ELSE 'PASSED'
        END AS validation_status
    FROM timestamp_cleaning
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE MEETING_ID IS NOT NULL
),

final_transformation AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        cleaned_start_time AS START_TIME,
        cleaned_end_time AS END_TIME,
        cleaned_duration_minutes AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
    AND validation_status != 'FAILED'
)

SELECT * FROM final_transformation
