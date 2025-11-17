{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Meetings table
-- Handles EST timezone conversion and data quality checks

WITH source_data AS (
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

timestamp_standardization AS (
    SELECT 
        *,
        -- Handle EST timezone conversion for START_TIME
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE START_TIME
        END AS standardized_start_time,
        
        -- Handle EST timezone conversion for END_TIME
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE END_TIME
        END AS standardized_end_time
    FROM source_data
),

data_quality_checks AS (
    SELECT 
        *,
        -- Calculate duration from standardized timestamps
        CASE 
            WHEN standardized_start_time IS NOT NULL AND standardized_end_time IS NOT NULL THEN
                DATEDIFF('minute', standardized_start_time, standardized_end_time)
            ELSE DURATION_MINUTES
        END AS calculated_duration,
        
        -- Data quality validations
        CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN HOST_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN standardized_start_time IS NULL THEN 0 ELSE 20 END +
        CASE WHEN standardized_end_time IS NULL THEN 0 ELSE 20 END +
        CASE WHEN standardized_end_time <= standardized_start_time THEN 0 ELSE 20 END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL THEN 'FAILED'
            WHEN standardized_start_time IS NULL OR standardized_end_time IS NULL THEN 'FAILED'
            WHEN standardized_end_time <= standardized_start_time THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM timestamp_standardization
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status != 'FAILED'  -- Exclude failed records
),

final_transformation AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        COALESCE(TRIM(MEETING_TOPIC), 'No Topic') AS MEETING_TOPIC,
        standardized_start_time AS START_TIME,
        standardized_end_time AS END_TIME,
        COALESCE(calculated_duration, 0) AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1  -- Keep only the latest record per MEETING_ID
)

SELECT * FROM final_transformation
