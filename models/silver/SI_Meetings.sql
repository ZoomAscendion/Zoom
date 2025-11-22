{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Layer Meetings Table */
/* Purpose: Cleaned and standardized meeting information with critical DQ checks */
/* Critical P1: Numeric field text unit cleaning for DURATION_MINUTES */
/* Critical P1: EST timezone format validation and conversion */

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
),

timestamp_cleaned AS (
    SELECT 
        *,
        /* Critical P1: EST timezone format cleaning and conversion */
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
        
        /* Critical P1: Numeric field text unit cleaning for DURATION_MINUTES */
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
        /* Data Quality Score Calculation */
        CASE 
            WHEN MEETING_ID IS NULL THEN 0
            WHEN HOST_ID IS NULL THEN 20
            WHEN CLEAN_START_TIME IS NULL OR CLEAN_END_TIME IS NULL THEN 40
            WHEN CLEAN_DURATION_MINUTES IS NULL THEN 50
            WHEN CLEAN_END_TIME <= CLEAN_START_TIME THEN 60
            WHEN CLEAN_DURATION_MINUTES < 0 OR CLEAN_DURATION_MINUTES > 1440 THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL THEN 'FAILED'
            WHEN CLEAN_START_TIME IS NULL OR CLEAN_END_TIME IS NULL OR CLEAN_DURATION_MINUTES IS NULL THEN 'FAILED'
            WHEN CLEAN_END_TIME <= CLEAN_START_TIME THEN 'FAILED'
            WHEN CLEAN_DURATION_MINUTES < 0 OR CLEAN_DURATION_MINUTES > 1440 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_cleaned
),

cleaned_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        CLEAN_START_TIME AS START_TIME,
        CLEAN_END_TIME AS END_TIME,
        CLEAN_DURATION_MINUTES AS DURATION_MINUTES,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
        DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM data_quality_checks
    WHERE MEETING_ID IS NOT NULL
      AND CLEAN_START_TIME IS NOT NULL
      AND CLEAN_END_TIME IS NOT NULL
      AND CLEAN_DURATION_MINUTES IS NOT NULL
      AND CLEAN_END_TIME > CLEAN_START_TIME
    QUALIFY ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) = 1
)

SELECT * FROM cleaned_meetings
