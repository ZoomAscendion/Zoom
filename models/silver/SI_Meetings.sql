{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_MEETINGS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Meetings Table - Cleaned and standardized meeting information with critical P1 numeric field cleaning */

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
),

cleaned_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        
        /* Critical P1 Fix: Clean EST timezone format from timestamps */
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
                    START_TIME
                )
        END AS START_TIME,
        
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
                    END_TIME
                )
        END AS END_TIME,
        
        /* Critical P1 Fix: Clean text units from DURATION_MINUTES field */
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
    WHERE MEETING_ID IS NOT NULL
),

validated_meetings AS (
    SELECT 
        *,
        /* Calculate actual duration from cleaned timestamps */
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME > START_TIME
            THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE CLEAN_DURATION_MINUTES
        END AS CALCULATED_DURATION,
        
        /* Data Quality Score Calculation */
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
                AND CLEAN_DURATION_MINUTES IS NOT NULL 
                AND CLEAN_DURATION_MINUTES >= 0 
                AND CLEAN_DURATION_MINUTES <= 1440
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL 
            THEN 80
            WHEN MEETING_ID IS NOT NULL 
            THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
                AND CLEAN_DURATION_MINUTES IS NOT NULL 
                AND CLEAN_DURATION_MINUTES >= 0 
                AND CLEAN_DURATION_MINUTES <= 1440
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_meetings
),

deduped_meetings AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
        FROM validated_meetings
    )
    WHERE rn = 1
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    COALESCE(CALCULATED_DURATION, CLEAN_DURATION_MINUTES) AS DURATION_MINUTES,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_meetings
WHERE VALIDATION_STATUS != 'FAILED'
