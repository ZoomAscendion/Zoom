{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) VALUES ('{{ invocation_id }}', 'SI_MEETINGS', CURRENT_TIMESTAMP(), 'RUNNING', 'BRONZE.BZ_MEETINGS', 'SILVER.SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}) WHERE EXECUTION_ID = '{{ invocation_id }}' AND TARGET_TABLE = 'SILVER.SI_MEETINGS'"
) }}

-- Silver Layer Meetings Table
-- Transforms and cleanses meeting data from Bronze layer
-- Handles EST timezone conversion and data quality validation

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

timestamp_converted AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        
        -- Enhanced EST timezone conversion for START_TIME
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(
                    CONVERT_TIMEZONE('America/New_York', 'UTC', 
                        TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
                    )
                )
            ELSE TRY_TO_TIMESTAMP(START_TIME)
        END AS START_TIME,
        
        -- Enhanced EST timezone conversion for END_TIME
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(
                    CONVERT_TIMEZONE('America/New_York', 'UTC', 
                        TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
                    )
                )
            ELSE TRY_TO_TIMESTAMP(END_TIME)
        END AS END_TIME,
        
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Track timestamp format for validation
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 'EST_CONVERTED'
            ELSE 'STANDARD'
        END AS TIMESTAMP_FORMAT_TYPE
    FROM bronze_meetings
    WHERE MEETING_ID IS NOT NULL
),

cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        
        -- Host ID validation (must exist in users)
        HOST_ID,
        
        -- Meeting topic sanitization
        CASE 
            WHEN MEETING_TOPIC IS NULL OR TRIM(MEETING_TOPIC) = '' THEN 'UNTITLED_MEETING'
            ELSE TRIM(MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Validated timestamps
        START_TIME,
        END_TIME,
        
        -- Duration validation and recalculation
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME > START_TIME THEN
                DATEDIFF('minute', START_TIME, END_TIME)
            WHEN DURATION_MINUTES IS NOT NULL AND DURATION_MINUTES >= 0 AND DURATION_MINUTES <= 1440 THEN
                DURATION_MINUTES
            ELSE 0
        END AS DURATION_MINUTES,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        TIMESTAMP_FORMAT_TYPE,
        
        -- Silver layer specific fields
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM timestamp_converted
    WHERE START_TIME IS NOT NULL 
      AND END_TIME IS NOT NULL
      AND START_TIME <= END_TIME
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score (0-100)
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL
                AND END_TIME > START_TIME
                AND DURATION_MINUTES > 0
                AND DURATION_MINUTES <= 1440
            THEN 100
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL
            THEN 80
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL
            THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL
                AND END_TIME > START_TIME
                AND DURATION_MINUTES > 0
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL
                AND START_TIME IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_meetings
),

-- Remove duplicates keeping the latest record
deduped_meetings AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    )
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
WHERE VALIDATION_STATUS != 'FAILED'
