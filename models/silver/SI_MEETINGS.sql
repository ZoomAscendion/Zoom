{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_MEETINGS' AND EXECUTION_STATUS = 'RUNNING' AND '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver Layer Meetings Table
-- Purpose: Clean and standardized meeting information with EST timezone handling
-- Source: Bronze.BZ_MEETINGS

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
    WHERE MEETING_ID IS NOT NULL
),

timestamp_standardization AS (
    SELECT 
        *,
        -- Enhanced EST timezone handling
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'DD/MM/YYYY HH24:MI')
                )
            ELSE START_TIME
        END AS standardized_start_time,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'DD/MM/YYYY HH24:MI')
                )
            ELSE END_TIME
        END AS standardized_end_time
    FROM source_data
),

data_quality_checks AS (
    SELECT 
        *,
        -- Validate duration consistency after timestamp standardization
        CASE 
            WHEN standardized_start_time IS NOT NULL AND standardized_end_time IS NOT NULL THEN
                DATEDIFF('minute', standardized_start_time, standardized_end_time)
            ELSE DURATION_MINUTES
        END AS calculated_duration,
        
        -- Data quality score calculation
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND standardized_start_time IS NOT NULL 
                AND standardized_end_time IS NOT NULL 
                AND standardized_end_time > standardized_start_time
                AND DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND standardized_start_time IS NOT NULL 
            THEN 75
            WHEN MEETING_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND standardized_start_time IS NOT NULL 
                AND standardized_end_time IS NOT NULL 
                AND standardized_end_time > standardized_start_time
                AND DURATION_MINUTES BETWEEN 0 AND 1440
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS validation_status
    FROM timestamp_standardization
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status IN ('PASSED', 'WARNING')
),

final_transformation AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        standardized_start_time AS START_TIME,
        standardized_end_time AS END_TIME,
        COALESCE(calculated_duration, DURATION_MINUTES) AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM deduplication
    WHERE row_num = 1
)

SELECT * FROM final_transformation
