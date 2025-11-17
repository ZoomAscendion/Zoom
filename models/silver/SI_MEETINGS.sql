{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_SUCCESS, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', CURRENT_TIMESTAMP(), 'COMPLETED', 'BZ_MEETINGS', 'SI_MEETINGS', (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Meetings table
-- Enhanced with EST timezone format validation and conversion

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

-- Enhanced timestamp format validation and conversion
timestamp_processed AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        
        -- Enhanced START_TIME processing with EST timezone validation
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                CASE 
                    WHEN REGEXP_LIKE(START_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN
                        CONVERT_TIMEZONE('America/New_York', 'UTC', 
                            TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
                    ELSE START_TIME -- Keep original if EST format is invalid
                END
            ELSE START_TIME
        END AS START_TIME,
        
        -- Enhanced END_TIME processing with EST timezone validation
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                CASE 
                    WHEN REGEXP_LIKE(END_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN
                        CONVERT_TIMEZONE('America/New_York', 'UTC', 
                            TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
                    ELSE END_TIME -- Keep original if EST format is invalid
                END
            ELSE END_TIME
        END AS END_TIME,
        
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_meetings
),

-- Data quality validation and cleansing
cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        
        -- Validate and recalculate duration if needed
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME > START_TIME THEN
                DATEDIFF('minute', START_TIME, END_TIME)
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Enhanced data quality score calculation including timestamp format compliance
        CASE 
            WHEN MEETING_ID IS NULL THEN 0
            WHEN HOST_ID IS NULL THEN 20
            WHEN START_TIME IS NULL OR END_TIME IS NULL THEN 40
            WHEN END_TIME <= START_TIME THEN 50
            WHEN DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440 THEN 60
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Enhanced validation status including timestamp format validation
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL OR START_TIME IS NULL OR END_TIME IS NULL THEN 'FAILED'
            WHEN END_TIME <= START_TIME OR DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440 THEN 'FAILED'
            WHEN MEETING_TOPIC IS NULL THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_processed
),

-- Remove duplicates keeping the latest record
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_meetings
    WHERE MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND END_TIME > START_TIME
)

-- Final select with additional Silver layer metadata
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_meetings
WHERE rn = 1
