{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_MEETINGS', 'SI_MEETINGS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Meetings Table
-- Transforms and cleanses meeting data from Bronze layer
-- Handles EST timezone format validation and conversion
-- Applies data quality validations and business rules

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

-- Timestamp format validation and conversion layer
timestamp_validated_meetings AS (
    SELECT 
        *,
        -- EST timezone format validation and conversion
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                CASE 
                    WHEN REGEXP_LIKE(START_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN
                        TRY_CAST(CONVERT_TIMEZONE('America/New_York', 'UTC', 
                            TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')) AS TIMESTAMP_NTZ(9))
                    ELSE NULL
                END
            ELSE START_TIME
        END AS standardized_start_time,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                CASE 
                    WHEN REGEXP_LIKE(END_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN
                        TRY_CAST(CONVERT_TIMEZONE('America/New_York', 'UTC', 
                            TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')) AS TIMESTAMP_NTZ(9))
                    ELSE NULL
                END
            ELSE END_TIME
        END AS standardized_end_time,
        
        -- Timestamp format validation flags
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                CASE 
                    WHEN REGEXP_LIKE(START_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN 1
                    ELSE 0
                END
            ELSE 1
        END AS start_time_format_valid,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                CASE 
                    WHEN REGEXP_LIKE(END_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN 1
                    ELSE 0
                END
            ELSE 1
        END AS end_time_format_valid
    FROM bronze_meetings
),

-- Data Quality and Validation Layer
validated_meetings AS (
    SELECT 
        *,
        -- Null checks
        CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 1 END AS meeting_id_valid,
        CASE WHEN HOST_ID IS NULL THEN 0 ELSE 1 END AS host_id_valid,
        CASE WHEN standardized_start_time IS NULL THEN 0 ELSE 1 END AS start_time_valid,
        CASE WHEN standardized_end_time IS NULL THEN 0 ELSE 1 END AS end_time_valid,
        
        -- Business logic validation
        CASE WHEN standardized_end_time > standardized_start_time THEN 1 ELSE 0 END AS time_logic_valid,
        CASE WHEN DURATION_MINUTES >= 0 AND DURATION_MINUTES <= 1440 THEN 1 ELSE 0 END AS duration_valid,
        
        -- Duration consistency check
        CASE 
            WHEN standardized_start_time IS NOT NULL AND standardized_end_time IS NOT NULL THEN
                CASE WHEN ABS(DURATION_MINUTES - DATEDIFF('minute', standardized_start_time, standardized_end_time)) <= 1 THEN 1 ELSE 0 END
            ELSE 0
        END AS duration_consistency_valid,
        
        -- Calculate data quality score
        ROUND((
            CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 15 END +
            CASE WHEN HOST_ID IS NULL THEN 0 ELSE 15 END +
            CASE WHEN standardized_start_time IS NULL THEN 0 ELSE 15 END +
            CASE WHEN standardized_end_time IS NULL THEN 0 ELSE 15 END +
            CASE WHEN standardized_end_time > standardized_start_time THEN 15 ELSE 0 END +
            CASE WHEN DURATION_MINUTES >= 0 AND DURATION_MINUTES <= 1440 THEN 10 END +
            CASE WHEN start_time_format_valid = 1 THEN 7.5 ELSE 0 END +
            CASE WHEN end_time_format_valid = 1 THEN 7.5 ELSE 0 END
        ), 0) AS data_quality_score
    FROM timestamp_validated_meetings
),

-- Deduplication layer using ROW_NUMBER to keep latest record
deduped_meetings AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM validated_meetings
    WHERE MEETING_ID IS NOT NULL  -- Remove null meeting IDs
),

-- Final transformation layer
final_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        standardized_start_time AS START_TIME,
        standardized_end_time AS END_TIME,
        CASE 
            WHEN standardized_start_time IS NOT NULL AND standardized_end_time IS NOT NULL THEN
                DATEDIFF('minute', standardized_start_time, standardized_end_time)
            ELSE DURATION_MINUTES
        END AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 90 THEN 'PASSED'
            WHEN data_quality_score >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduped_meetings
    WHERE row_num = 1  -- Keep only the latest record per meeting
    AND data_quality_score >= 70  -- Only pass records with acceptable quality
    AND standardized_start_time IS NOT NULL
    AND standardized_end_time IS NOT NULL
    AND standardized_end_time > standardized_start_time
)

SELECT * FROM final_meetings
