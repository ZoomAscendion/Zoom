{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }} LIMIT 1)",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()) WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_PARTICIPANTS' AND EXECUTION_STATUS = 'RUNNING' AND EXISTS (SELECT 1 FROM {{ ref('SI_Audit_Log') }} WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_PARTICIPANTS')"
) }}

-- Silver layer transformation for Participants table
-- Handles MM/DD/YYYY HH:MM format conversion and data quality checks

WITH source_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
),

timestamp_standardization AS (
    SELECT 
        *,
        -- Handle MM/DD/YYYY HH:MM format conversion for JOIN_TIME
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS standardized_join_time,
        
        -- Handle MM/DD/YYYY HH:MM format conversion for LEAVE_TIME
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE LEAVE_TIME
        END AS standardized_leave_time,
        
        -- Validate MM/DD/YYYY format
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' AND TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NULL THEN 'INVALID_MMDDYYYY_FORMAT'
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' AND TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NULL THEN 'INVALID_MMDDYYYY_FORMAT'
            ELSE 'VALID_FORMAT'
        END AS timestamp_format_status
    FROM source_data
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality validations
        CASE WHEN PARTICIPANT_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN USER_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN standardized_join_time IS NULL THEN 0 ELSE 20 END +
        CASE WHEN standardized_leave_time IS NULL OR standardized_leave_time <= standardized_join_time THEN 0 ELSE 20 END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN standardized_join_time IS NULL OR standardized_leave_time IS NULL THEN 'FAILED'
            WHEN standardized_leave_time <= standardized_join_time OR timestamp_format_status = 'INVALID_MMDDYYYY_FORMAT' THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM timestamp_standardization
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status != 'FAILED'  -- Exclude failed records
),

final_transformation AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        standardized_join_time AS JOIN_TIME,
        standardized_leave_time AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1  -- Keep only the latest record per PARTICIPANT_ID
)

SELECT * FROM final_transformation
