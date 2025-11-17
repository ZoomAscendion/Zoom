{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_MEETINGS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_MEETINGS', 'SI_MEETINGS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

-- SI_MEETINGS: Cleaned and standardized meeting information with EST timezone handling
-- Enhanced transformation with timestamp format validation for EST timezone issues

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
    FROM BRONZE.BZ_MEETINGS
    WHERE MEETING_ID IS NOT NULL  -- Exclude records with null MEETING_ID
),

timestamp_format_validation AS (
    SELECT 
        *,
        -- Enhanced EST timezone format validation and conversion
        CASE 
            WHEN START_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'MM/DD/YYYY HH24:MI')
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(START_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    START_TIME
                )
        END AS STANDARDIZED_START_TIME,
        
        CASE 
            WHEN END_TIME::STRING LIKE '%EST%' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'MM/DD/YYYY HH24:MI')
                )
            ELSE 
                COALESCE(
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(END_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    END_TIME
                )
        END AS STANDARDIZED_END_TIME
    FROM source_data
),

data_quality_validation AS (
    SELECT 
        *,
        -- Calculate actual duration from standardized timestamps
        DATEDIFF('minute', STANDARDIZED_START_TIME, STANDARDIZED_END_TIME) AS CALCULATED_DURATION,
        
        -- Data Quality Score Calculation
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND STANDARDIZED_START_TIME IS NOT NULL 
                AND STANDARDIZED_END_TIME IS NOT NULL 
                AND STANDARDIZED_END_TIME > STANDARDIZED_START_TIME
                AND DURATION_MINUTES BETWEEN 0 AND 1440
                AND ABS(DURATION_MINUTES - DATEDIFF('minute', STANDARDIZED_START_TIME, STANDARDIZED_END_TIME)) <= 1
            THEN 100
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL AND STANDARDIZED_START_TIME IS NOT NULL 
            THEN 75
            WHEN MEETING_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN MEETING_ID IS NOT NULL 
                AND HOST_ID IS NOT NULL 
                AND STANDARDIZED_START_TIME IS NOT NULL 
                AND STANDARDIZED_END_TIME IS NOT NULL 
                AND STANDARDIZED_END_TIME > STANDARDIZED_START_TIME
            THEN 'PASSED'
            WHEN MEETING_ID IS NOT NULL AND HOST_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM timestamp_format_validation
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_validation
),

final_transformation AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        TRIM(MEETING_TOPIC) AS MEETING_TOPIC,
        STANDARDIZED_START_TIME AS START_TIME,
        STANDARDIZED_END_TIME AS END_TIME,
        COALESCE(CALCULATED_DURATION, DURATION_MINUTES, 0) AS DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1  -- Keep only the latest record per MEETING_ID
        AND VALIDATION_STATUS != 'FAILED'  -- Exclude failed records from Silver layer
        AND STANDARDIZED_START_TIME IS NOT NULL  -- Ensure timestamp conversion succeeded
)

SELECT * FROM final_transformation
