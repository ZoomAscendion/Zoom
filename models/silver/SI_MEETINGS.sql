{{ config(
    materialized='table',
    pre_hook="{% if this.name != 'SI_Audit_Log' %}INSERT INTO {{ target.schema }}.SI_AUDIT_LOG (TABLE_NAME, STATUS, PROCESS_START_TIME, PROCESSED_BY, CREATED_AT) SELECT 'SI_MEETINGS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP(){% endif %}",
    post_hook="{% if this.name != 'SI_Audit_Log' %}INSERT INTO {{ target.schema }}.SI_AUDIT_LOG (TABLE_NAME, STATUS, PROCESS_END_TIME, PROCESSED_BY, RECORDS_PROCESSED, UPDATED_AT) SELECT 'SI_MEETINGS', 'COMPLETED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP(){% endif %}"
) }}

-- Silver layer transformation for Meetings table
-- Applies data quality checks, timestamp format validation, and duration text cleaning

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
    WHERE MEETING_ID IS NOT NULL  -- Remove null meeting IDs
),

data_quality_checks AS (
    SELECT 
        *,
        -- Clean duration text units (Critical P1 fix for "108 mins" error)
        CASE 
            WHEN DURATION_MINUTES::STRING REGEXP '[a-zA-Z]' THEN 
                TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', ''))
            ELSE DURATION_MINUTES
        END AS CLEAN_DURATION_MINUTES,
        
        -- Timestamp format validation and conversion
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS CLEAN_START_TIME,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS CLEAN_END_TIME,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_meetings
),

cleansed_meetings AS (
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
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality score calculation
        CASE 
            WHEN CLEAN_START_TIME IS NOT NULL 
                 AND CLEAN_END_TIME IS NOT NULL 
                 AND CLEAN_DURATION_MINUTES IS NOT NULL 
                 AND CLEAN_END_TIME > CLEAN_START_TIME 
                 AND CLEAN_DURATION_MINUTES > 0 
                 AND CLEAN_DURATION_MINUTES <= 1440 THEN 100
            WHEN CLEAN_START_TIME IS NOT NULL 
                 AND CLEAN_END_TIME IS NOT NULL 
                 AND CLEAN_DURATION_MINUTES IS NOT NULL THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN CLEAN_START_TIME IS NOT NULL 
                 AND CLEAN_END_TIME IS NOT NULL 
                 AND CLEAN_DURATION_MINUTES IS NOT NULL 
                 AND CLEAN_END_TIME > CLEAN_START_TIME 
                 AND CLEAN_DURATION_MINUTES > 0 
                 AND CLEAN_DURATION_MINUTES <= 1440 THEN 'PASSED'
            WHEN CLEAN_START_TIME IS NOT NULL 
                 AND CLEAN_END_TIME IS NOT NULL 
                 AND CLEAN_DURATION_MINUTES IS NOT NULL THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM data_quality_checks
    WHERE rn = 1  -- Keep only the latest record for each meeting
      AND CLEAN_START_TIME IS NOT NULL  -- Ensure valid timestamps
      AND CLEAN_END_TIME IS NOT NULL
      AND CLEAN_DURATION_MINUTES IS NOT NULL
      AND CLEAN_END_TIME > CLEAN_START_TIME  -- Business logic validation
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
    VALIDATION_STATUS,
    CREATED_AT,
    UPDATED_AT
FROM cleansed_meetings
