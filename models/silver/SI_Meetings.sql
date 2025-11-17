{{ config(
    materialized='table'
) }}

-- Silver Meetings table transformation from Bronze layer
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
    FROM BRONZE.BZ_MEETINGS
),

-- Handle EST timezone conversion and data cleansing
cleansed_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        
        -- Handle EST timezone conversion for START_TIME
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_CAST(
                    CONVERT_TIMEZONE('America/New_York', 'UTC', 
                        TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
                    ) AS TIMESTAMP_NTZ(9)
                )
            ELSE START_TIME
        END AS START_TIME,
        
        -- Handle EST timezone conversion for END_TIME
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_CAST(
                    CONVERT_TIMEZONE('America/New_York', 'UTC', 
                        TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
                    ) AS TIMESTAMP_NTZ(9)
                )
            ELSE END_TIME
        END AS END_TIME,
        
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_meetings
    WHERE MEETING_ID IS NOT NULL
),

-- Validate meeting logic and calculate data quality
validated_meetings AS (
    SELECT 
        *,
        
        -- Recalculate duration after timezone conversion
        DATEDIFF('minute', START_TIME, END_TIME) AS CALCULATED_DURATION,
        
        -- Data quality scoring
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND START_TIME IS NOT NULL 
                AND END_TIME IS NOT NULL 
                AND END_TIME > START_TIME
                AND DURATION_MINUTES > 0
                AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) <= 1
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL 
            THEN 75
            WHEN MEETING_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL THEN 'FAILED'
            WHEN START_TIME IS NULL OR END_TIME IS NULL THEN 'FAILED'
            WHEN END_TIME <= START_TIME THEN 'FAILED'
            WHEN DURATION_MINUTES <= 0 OR DURATION_MINUTES > 1440 THEN 'WARNING'
            WHEN ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM cleansed_meetings
),

-- Remove duplicates keeping the latest record
deduped_meetings AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
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
    CASE 
        WHEN VALIDATION_STATUS = 'PASSED' AND ABS(DURATION_MINUTES - CALCULATED_DURATION) <= 1 
        THEN DURATION_MINUTES
        ELSE CALCULATED_DURATION
    END AS DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_meetings
WHERE VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
