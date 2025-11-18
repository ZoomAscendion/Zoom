{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE EXISTS (SELECT 1 FROM BRONZE.BZ_MEETINGS LIMIT 1)",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE EXISTS (SELECT 1 FROM {{ this }} LIMIT 1)"
) }}

-- Silver Layer Meetings Table
-- Cleansed and standardized meeting information with critical P1 numeric field cleaning

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

cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        
        /* Critical P1: EST timezone format handling */
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
        END AS START_TIME,
        
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
        END AS END_TIME,
        
        /* Critical P1: Numeric field text unit cleaning for "108 mins" error */
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE TRY_TO_NUMBER(DURATION_MINUTES::STRING)
        END AS CLEAN_DURATION_MINUTES,
        
        DURATION_MINUTES AS ORIGINAL_DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_meetings
),

validated_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        CLEAN_DURATION_MINUTES AS DURATION_MINUTES,
        ORIGINAL_DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        /* Data quality score calculation */
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND CLEAN_DURATION_MINUTES IS NOT NULL
                AND END_TIME > START_TIME
                AND CLEAN_DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND CLEAN_DURATION_MINUTES IS NOT NULL
                AND END_TIME > START_TIME
                AND CLEAN_DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_meetings
),

/* Remove duplicates - keep latest record */
deduped_meetings AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
        FROM validated_meetings
    ) ranked
    WHERE rn = 1
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
FROM deduped_meetings
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
