{{ config(materialized='table') }}

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_MEETINGS') }}
),

cleaned_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(START_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    CURRENT_TIMESTAMP()
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING),
                    CURRENT_TIMESTAMP()
                )
        END AS CLEANED_START_TIME,
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REGEXP_REPLACE(END_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    CURRENT_TIMESTAMP()
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING),
                    CURRENT_TIMESTAMP()
                )
        END AS CLEANED_END_TIME,
        CASE 
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            WHEN TRY_TO_NUMBER(DURATION_MINUTES::STRING) IS NOT NULL THEN
                TRY_TO_NUMBER(DURATION_MINUTES::STRING)
            ELSE 0
        END AS CLEANED_DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_meetings
    WHERE MEETING_ID IS NOT NULL
),

validated_meetings AS (
    SELECT *,
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND CLEANED_START_TIME IS NOT NULL 
                AND CLEANED_END_TIME IS NOT NULL 
                AND CLEANED_DURATION_MINUTES IS NOT NULL
                AND CLEANED_END_TIME >= CLEANED_START_TIME
                AND CLEANED_DURATION_MINUTES >= 0
                AND CLEANED_DURATION_MINUTES <= 1440
            THEN 95
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND CLEANED_START_TIME IS NOT NULL 
                AND CLEANED_END_TIME IS NOT NULL 
                AND CLEANED_DURATION_MINUTES IS NOT NULL
                AND CLEANED_END_TIME >= CLEANED_START_TIME
                AND CLEANED_DURATION_MINUTES >= 0
                AND CLEANED_DURATION_MINUTES <= 1440
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_meetings
),

deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_meetings
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    CLEANED_START_TIME AS START_TIME,
    CLEANED_END_TIME AS END_TIME,
    CLEANED_DURATION_MINUTES AS DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_meetings
WHERE rn = 1
