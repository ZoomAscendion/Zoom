{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_MEETINGS', 'SI_MEETINGS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Meetings table
-- Applies data quality checks, duration validation, and referential integrity

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
    WHERE MEETING_ID IS NOT NULL
),

-- Validate meeting data and calculate quality score
validated_meetings AS (
    SELECT 
        *,
        -- Validate duration consistency
        ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) AS duration_diff,
        
        -- Calculate data quality score
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
                AND DURATION_MINUTES >= 0 
                AND DURATION_MINUTES <= 1440
                AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) <= 1
            THEN 100
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
            THEN 75
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS data_quality_score,
        
        -- Set validation status
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
                AND DURATION_MINUTES >= 0 
                AND DURATION_MINUTES <= 1440
                AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) <= 1
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS validation_status
    FROM bronze_meetings
),

-- Remove duplicates keeping the latest record
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_meetings
    WHERE validation_status IN ('PASSED', 'WARNING')
)

SELECT 
    MEETING_ID,
    HOST_ID,
    TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
    START_TIME,
    END_TIME,
    CASE 
        WHEN DURATION_MINUTES IS NOT NULL AND DURATION_MINUTES >= 0 AND DURATION_MINUTES <= 1440
        THEN DURATION_MINUTES
        ELSE DATEDIFF('minute', START_TIME, END_TIME)
    END AS DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    data_quality_score AS DATA_QUALITY_SCORE,
    validation_status AS VALIDATION_STATUS
FROM deduped_meetings
WHERE rn = 1
