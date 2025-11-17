{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_START_TIME, PROCESSED_BY, CREATED_AT) SELECT 'SI_PARTICIPANTS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_END_TIME, PROCESSED_BY, RECORDS_PROCESSED, UPDATED_AT) SELECT 'SI_PARTICIPANTS', 'COMPLETED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Participants table
-- Applies data quality checks and MM/DD/YYYY timestamp format validation

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
    WHERE PARTICIPANT_ID IS NOT NULL  -- Remove null participant IDs
),

data_quality_checks AS (
    SELECT 
        *,
        -- MM/DD/YYYY HH:MM timestamp format conversion
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS CLEAN_JOIN_TIME,
        
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE LEAVE_TIME
        END AS CLEAN_LEAVE_TIME,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_participants
),

cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        CLEAN_JOIN_TIME AS JOIN_TIME,
        CLEAN_LEAVE_TIME AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality score calculation
        CASE 
            WHEN CLEAN_JOIN_TIME IS NOT NULL 
                 AND CLEAN_LEAVE_TIME IS NOT NULL 
                 AND CLEAN_LEAVE_TIME > CLEAN_JOIN_TIME THEN 100
            WHEN CLEAN_JOIN_TIME IS NOT NULL 
                 AND CLEAN_LEAVE_TIME IS NOT NULL THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN CLEAN_JOIN_TIME IS NOT NULL 
                 AND CLEAN_LEAVE_TIME IS NOT NULL 
                 AND CLEAN_LEAVE_TIME > CLEAN_JOIN_TIME THEN 'PASSED'
            WHEN CLEAN_JOIN_TIME IS NOT NULL 
                 AND CLEAN_LEAVE_TIME IS NOT NULL THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM data_quality_checks
    WHERE rn = 1  -- Keep only the latest record for each participant
      AND CLEAN_JOIN_TIME IS NOT NULL  -- Ensure valid timestamps
      AND CLEAN_LEAVE_TIME IS NOT NULL
      AND CLEAN_LEAVE_TIME > CLEAN_JOIN_TIME  -- Business logic validation
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS,
    CREATED_AT,
    UPDATED_AT
FROM cleansed_participants
