{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Participants Table
-- Transforms and cleanses participant data from Bronze layer
-- Handles MM/DD/YYYY HH:MM format validation and conversion
-- Applies data quality validations and business rules

WITH bronze_participants AS (
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

-- Timestamp format validation and conversion layer
timestamp_validated_participants AS (
    SELECT 
        *,
        -- MM/DD/YYYY HH:MM format validation and conversion
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS standardized_join_time,
        
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE LEAVE_TIME
        END AS standardized_leave_time,
        
        -- Timestamp format validation flags
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                CASE WHEN TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NOT NULL THEN 1 ELSE 0 END
            ELSE 1
        END AS join_time_format_valid,
        
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                CASE WHEN TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NOT NULL THEN 1 ELSE 0 END
            ELSE 1
        END AS leave_time_format_valid
    FROM bronze_participants
),

-- Data Quality and Validation Layer
validated_participants AS (
    SELECT 
        *,
        -- Null checks
        CASE WHEN PARTICIPANT_ID IS NULL THEN 0 ELSE 1 END AS participant_id_valid,
        CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 1 END AS meeting_id_valid,
        CASE WHEN USER_ID IS NULL THEN 0 ELSE 1 END AS user_id_valid,
        CASE WHEN standardized_join_time IS NULL THEN 0 ELSE 1 END AS join_time_valid,
        CASE WHEN standardized_leave_time IS NULL THEN 0 ELSE 1 END AS leave_time_valid,
        
        -- Business logic validation
        CASE WHEN standardized_leave_time > standardized_join_time THEN 1 ELSE 0 END AS time_logic_valid,
        
        -- Calculate data quality score
        ROUND((
            CASE WHEN PARTICIPANT_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN MEETING_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN USER_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN standardized_join_time IS NULL THEN 0 ELSE 15 END +
            CASE WHEN standardized_leave_time IS NULL THEN 0 ELSE 15 END +
            CASE WHEN join_time_format_valid = 1 THEN 5 ELSE 0 END +
            CASE WHEN leave_time_format_valid = 1 THEN 5 ELSE 0 END
        ), 0) AS data_quality_score
    FROM timestamp_validated_participants
),

-- Deduplication layer using ROW_NUMBER to keep latest record
deduped_participants AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM validated_participants
    WHERE PARTICIPANT_ID IS NOT NULL  -- Remove null participant IDs
),

-- Final transformation layer
final_participants AS (
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
        CASE 
            WHEN data_quality_score >= 90 THEN 'PASSED'
            WHEN data_quality_score >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduped_participants
    WHERE row_num = 1  -- Keep only the latest record per participant
    AND data_quality_score >= 70  -- Only pass records with acceptable quality
    AND standardized_join_time IS NOT NULL
    AND standardized_leave_time IS NOT NULL
    AND standardized_leave_time > standardized_join_time
)

SELECT * FROM final_participants
