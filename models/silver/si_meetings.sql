{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('si_audit_log') }} (
            EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, 
            SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP
        )
        VALUES (
            '{{ invocation_id }}', 
            'si_meetings', 
            CURRENT_TIMESTAMP(), 
            'RUNNING', 
            'BRONZE.BZ_MEETINGS', 
            'SILVER.SI_MEETINGS', 
            'DBT_SILVER_PIPELINE', 
            CURRENT_TIMESTAMP()
        )",
    post_hook="
        UPDATE {{ ref('si_audit_log') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }})
        WHERE EXECUTION_ID = '{{ invocation_id }}' 
        AND TARGET_TABLE = 'SILVER.SI_MEETINGS'"
) }}

-- Silver layer meetings table with timestamp format handling and duration text cleaning
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
      AND HOST_ID IS NOT NULL
),

cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        -- Handle EST timezone format in START_TIME
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS START_TIME,
        -- Handle EST timezone format in END_TIME
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS END_TIME,
        /* Clean duration text units (Critical P1 fix for "108 mins" error) */
        CASE 
            WHEN DURATION_MINUTES::STRING REGEXP '[a-zA-Z]' THEN 
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_meetings
),

validated_meetings AS (
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
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality scoring
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL 
                 AND END_TIME > START_TIME AND DURATION_MINUTES > 0 
                 AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) <= 1 THEN 100
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME > START_TIME THEN 80
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL 
                 AND END_TIME > START_TIME AND DURATION_MINUTES > 0 THEN 'PASSED'
            WHEN END_TIME <= START_TIME THEN 'FAILED'
            WHEN DURATION_MINUTES <= 0 OR DURATION_MINUTES > 1440 THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_meetings
    WHERE rn = 1
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND END_TIME > START_TIME  -- Business logic validation
      AND DURATION_MINUTES > 0
      AND DURATION_MINUTES <= 1440  -- Max 24 hours
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
FROM validated_meetings
