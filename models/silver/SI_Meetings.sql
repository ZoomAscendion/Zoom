{{ config(
    materialized='table',
    pre_hook="INSERT INTO SILVER.SI_AUDIT_LOG (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="UPDATE SILVER.SI_AUDIT_LOG SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_SUCCESS = (SELECT COUNT(*) FROM SILVER.SI_MEETINGS), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_MEETINGS' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Silver Layer Meetings Table
-- Transforms and cleanses meeting data from Bronze layer
-- Applies data quality checks and business rules

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
),

cleansed_meetings AS (
    SELECT 
        -- Direct mappings with validation
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        -- Calculated duration for validation
        DATEDIFF('minute', START_TIME, END_TIME) AS CALCULATED_DURATION
    FROM bronze_meetings
    WHERE MEETING_ID IS NOT NULL
        AND START_TIME IS NOT NULL
        AND END_TIME IS NOT NULL
        AND END_TIME > START_TIME
        AND DURATION_MINUTES >= 0
        AND DURATION_MINUTES <= 1440
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
                AND DURATION_MINUTES IS NOT NULL
                AND ABS(DURATION_MINUTES - CALCULATED_DURATION) <= 1
                AND EXISTS (SELECT 1 FROM SILVER.SI_USERS u WHERE u.USER_ID = HOST_ID)
            THEN 100
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
            THEN 75
            WHEN MEETING_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Set validation status
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
                AND DURATION_MINUTES IS NOT NULL
                AND ABS(DURATION_MINUTES - CALCULATED_DURATION) <= 1
                AND EXISTS (SELECT 1 FROM SILVER.SI_USERS u WHERE u.USER_ID = HOST_ID)
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
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
