{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_PARTICIPANTS' AND EXECUTION_STATUS = 'RUNNING' AND '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver Layer Participants Table
-- Purpose: Clean and standardized meeting participants with MM/DD/YYYY format handling
-- Source: Bronze.BZ_PARTICIPANTS

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
    WHERE PARTICIPANT_ID IS NOT NULL
),

timestamp_standardization AS (
    SELECT 
        *,
        -- Enhanced MM/DD/YYYY HH:MM format handling
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS')
                )
            WHEN JOIN_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(JOIN_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE JOIN_TIME
        END AS standardized_join_time,
        
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                COALESCE(
                    TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
                    TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS')
                )
            WHEN LEAVE_TIME::STRING LIKE '%EST%' THEN 
                TRY_TO_TIMESTAMP(REPLACE(LEAVE_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
            ELSE LEAVE_TIME
        END AS standardized_leave_time
    FROM source_data
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality score calculation
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND standardized_join_time IS NOT NULL 
                AND standardized_leave_time IS NOT NULL 
                AND standardized_leave_time > standardized_join_time
            THEN 100
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 75
            WHEN PARTICIPANT_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND standardized_join_time IS NOT NULL 
                AND standardized_leave_time IS NOT NULL 
                AND standardized_leave_time > standardized_join_time
            THEN 'PASSED'
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS validation_status
    FROM timestamp_standardization
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status IN ('PASSED', 'WARNING')
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
