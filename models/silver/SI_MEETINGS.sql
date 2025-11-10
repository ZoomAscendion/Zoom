{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Meetings table
-- Applies data quality checks, time validation, and business rules

WITH bronze_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        -- Use columns as-is since they're already timestamps
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM BRONZE.BZ_MEETINGS
),

-- Data quality validation and cleansing
cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate actual duration for validation (only if both timestamps are valid)
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL 
            THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE NULL
        END AS CALCULATED_DURATION,
        
        -- Data quality scoring
        CASE 
            WHEN MEETING_ID IS NULL THEN 0
            WHEN HOST_ID IS NULL THEN 20
            WHEN START_TIME IS NULL OR END_TIME IS NULL THEN 30
            WHEN END_TIME <= START_TIME THEN 40
            WHEN DURATION_MINUTES IS NULL OR DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440 THEN 50
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL 
                 AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1 THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL THEN 'FAILED'
            WHEN START_TIME IS NULL OR END_TIME IS NULL THEN 'FAILED'
            WHEN END_TIME <= START_TIME THEN 'FAILED'
            WHEN DURATION_MINUTES IS NULL OR DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440 THEN 'FAILED'
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL 
                 AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_meetings
),

-- Remove duplicates using ROW_NUMBER
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_meetings
    WHERE MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
      AND START_TIME IS NOT NULL
      AND END_TIME IS NOT NULL
      AND END_TIME > START_TIME
      AND DURATION_MINUTES IS NOT NULL
      AND DURATION_MINUTES >= 0
      AND DURATION_MINUTES <= 1440
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_meetings
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
