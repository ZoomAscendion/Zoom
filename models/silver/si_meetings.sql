{{ config(
    materialized='table'
) }}

-- Silver Layer Meetings Table
-- Transforms and cleanses meeting data from Bronze layer
-- Handles multiple timestamp formats including DD/MM/YYYY HH:MM and EST timezone

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
),

-- Timestamp Format Validation and Conversion
timestamp_processed AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        
        -- Handle multiple timestamp formats
        CASE 
            -- Handle EST timezone format
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(
                    REPLACE(START_TIME::STRING, ' EST', ''), 
                    'YYYY-MM-DD HH24:MI:SS'
                )
            -- Handle DD/MM/YYYY HH:MM format
            WHEN START_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(START_TIME::STRING, 'DD/MM/YYYY HH24:MI')
            -- Handle MM/DD/YYYY HH:MM format
            WHEN START_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'MM/DD/YYYY HH24:MI')
                )
            ELSE START_TIME
        END AS START_TIME,
        
        CASE 
            -- Handle EST timezone format
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(
                    REPLACE(END_TIME::STRING, ' EST', ''), 
                    'YYYY-MM-DD HH24:MI:SS'
                )
            -- Handle DD/MM/YYYY HH:MM format
            WHEN END_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(END_TIME::STRING, 'DD/MM/YYYY HH24:MI')
            -- Handle MM/DD/YYYY HH:MM format
            WHEN END_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'MM/DD/YYYY HH24:MI')
                )
            ELSE END_TIME
        END AS END_TIME,
        
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Track timestamp format issues
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' AND TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS') IS NULL THEN 'EST_FORMAT_ERROR'
            WHEN END_TIME::STRING LIKE '%EST%' AND TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS') IS NULL THEN 'EST_FORMAT_ERROR'
            WHEN START_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
                 AND TRY_TO_TIMESTAMP(START_TIME::STRING, 'DD/MM/YYYY HH24:MI') IS NULL 
                 AND TRY_TO_TIMESTAMP(START_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NULL THEN 'DATE_FORMAT_ERROR'
            WHEN END_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' 
                 AND TRY_TO_TIMESTAMP(END_TIME::STRING, 'DD/MM/YYYY HH24:MI') IS NULL 
                 AND TRY_TO_TIMESTAMP(END_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NULL THEN 'DATE_FORMAT_ERROR'
            ELSE 'FORMAT_OK'
        END AS TIMESTAMP_FORMAT_STATUS
    FROM bronze_meetings
),

-- Data Quality and Business Logic Validation
cleansed_meetings AS (
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
        TIMESTAMP_FORMAT_STATUS,
        
        -- Validate duration consistency
        CASE 
            WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL THEN
                DATEDIFF('minute', START_TIME, END_TIME)
            ELSE NULL
        END AS CALCULATED_DURATION,
        
        -- Data Quality Scoring
        CASE 
            WHEN MEETING_ID IS NULL THEN 0
            WHEN HOST_ID IS NULL THEN 20
            WHEN START_TIME IS NULL OR END_TIME IS NULL THEN 30
            WHEN TIMESTAMP_FORMAT_STATUS IN ('EST_FORMAT_ERROR', 'DATE_FORMAT_ERROR') THEN 40
            WHEN END_TIME <= START_TIME THEN 50
            WHEN DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440 THEN 60
            WHEN ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1 THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL OR START_TIME IS NULL OR END_TIME IS NULL THEN 'FAILED'
            WHEN TIMESTAMP_FORMAT_STATUS IN ('EST_FORMAT_ERROR', 'DATE_FORMAT_ERROR') OR END_TIME <= START_TIME THEN 'FAILED'
            WHEN DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440 THEN 'WARNING'
            WHEN ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_processed
),

-- Remove duplicates - keep latest record
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_meetings
    WHERE MEETING_ID IS NOT NULL
      AND TIMESTAMP_FORMAT_STATUS = 'FORMAT_OK'
)

-- Final Select with Silver layer metadata
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
  AND VALIDATION_STATUS != 'FAILED'
