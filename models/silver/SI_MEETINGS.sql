{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

/* Silver layer meetings table with enhanced timestamp format handling and numeric field cleaning */

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
),

format_conversion AS (
    SELECT 
        *,
        /* Clean timezone text patterns before timestamp conversion */
        REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', '') AS clean_start_time_str,
        REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', '') AS clean_end_time_str,
        
        /* Critical P1: Clean text units from DURATION_MINUTES field */
        TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) AS clean_duration_minutes,
        
        /* Multi-format timestamp parsing */
        COALESCE(
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'MM/DD/YYYY HH24:MI')
        ) AS converted_start_time,
        
        COALESCE(
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'MM/DD/YYYY HH24:MI')
        ) AS converted_end_time
    FROM bronze_meetings
),

data_quality_checks AS (
    SELECT 
        *,
        /* Calculate duration from converted timestamps */
        CASE 
            WHEN converted_start_time IS NOT NULL AND converted_end_time IS NOT NULL THEN
                DATEDIFF('minute', converted_start_time, converted_end_time)
            ELSE clean_duration_minutes
        END AS calculated_duration,
        
        /* Data quality score calculation */
        (
            CASE WHEN MEETING_ID IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN HOST_ID IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN converted_start_time IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN converted_end_time IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN clean_duration_minutes IS NOT NULL AND clean_duration_minutes >= 0 AND clean_duration_minutes <= 1440 THEN 20 ELSE 0 END +
            CASE WHEN LOAD_TIMESTAMP IS NOT NULL THEN 10 ELSE 0 END
        ) AS data_quality_score,
        
        /* Validation status */
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL THEN 'FAILED'
            WHEN converted_start_time IS NULL OR converted_end_time IS NULL THEN 'FAILED'
            WHEN clean_duration_minutes IS NULL OR clean_duration_minutes < 0 OR clean_duration_minutes > 1440 THEN 'FAILED'
            WHEN converted_end_time <= converted_start_time THEN 'FAILED'
            WHEN ABS(COALESCE(clean_duration_minutes, 0) - COALESCE(DATEDIFF('minute', converted_start_time, converted_end_time), 0)) > 5 THEN 'WARNING'
            ELSE 'PASSED'
        END AS validation_status
    FROM format_conversion
),

cleaned_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        converted_start_time AS START_TIME,
        converted_end_time AS END_TIME,
        COALESCE(clean_duration_minutes, calculated_duration) AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score,
        validation_status
    FROM data_quality_checks
    WHERE MEETING_ID IS NOT NULL
    AND converted_start_time IS NOT NULL
    AND converted_end_time IS NOT NULL
    AND clean_duration_minutes IS NOT NULL
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
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
    data_quality_score AS DATA_QUALITY_SCORE,
    validation_status AS VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
AND validation_status != 'FAILED'
