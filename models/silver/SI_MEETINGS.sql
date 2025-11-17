{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }} LIMIT 1)",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()) WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_MEETINGS' AND EXECUTION_STATUS = 'RUNNING' AND EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }} WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_MEETINGS')"
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
                CONVERT_TIMEZONE('America/New_York', 'UTC', 
                    TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
            ELSE START_TIME
        END AS standardized_start_time,
        
        -- Handle EST timezone conversion for END_TIME
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                CONVERT_TIMEZONE('America/New_York', 'UTC', 
                    TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
            ELSE END_TIME
        END AS standardized_end_time,
        
        -- Validate EST timezone format
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' AND NOT REGEXP_LIKE(START_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN 'INVALID_EST_FORMAT'
            WHEN END_TIME::STRING LIKE '%EST%' AND NOT REGEXP_LIKE(END_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN 'INVALID_EST_FORMAT'
            ELSE 'VALID_FORMAT'
        END AS timestamp_format_status
    FROM source_data
),

data_quality_checks AS (
    SELECT 
        *,
        -- Calculate duration from standardized timestamps
        DATEDIFF('minute', standardized_start_time, standardized_end_time) AS calculated_duration,
        
        -- Data quality validations
        CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN HOST_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN standardized_start_time IS NULL THEN 0 ELSE 20 END +
        CASE WHEN standardized_end_time IS NULL OR standardized_end_time <= standardized_start_time THEN 0 ELSE 20 END +
        CASE WHEN timestamp_format_status = 'INVALID_EST_FORMAT' THEN 0 ELSE 20 END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NULL OR HOST_ID IS NULL OR standardized_start_time IS NULL OR standardized_end_time IS NULL THEN 'FAILED'
            WHEN standardized_end_time <= standardized_start_time OR timestamp_format_status = 'INVALID_EST_FORMAT' THEN 'FAILED'
            WHEN ABS(DURATION_MINUTES - DATEDIFF('minute', standardized_start_time, standardized_end_time)) > 1 THEN 'WARNING'
            ELSE 'PASSED'
        END AS validation_status
    FROM timestamp_standardization
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status != 'FAILED'  -- Exclude failed records
),

final_transformation AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        standardized_start_time AS START_TIME,
        standardized_end_time AS END_TIME,
        calculated_duration AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1  -- Keep only the latest record per MEETING_ID
)

SELECT * FROM final_transformation
