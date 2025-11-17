{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_SUCCESS, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', CURRENT_TIMESTAMP(), 'COMPLETED', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Participants table
-- Enhanced with MM/DD/YYYY HH:MM format validation and conversion

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

-- Enhanced timestamp format validation and conversion
timestamp_processed AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Enhanced JOIN_TIME processing with MM/DD/YYYY HH:MM format validation
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        -- Enhanced LEAVE_TIME processing with MM/DD/YYYY HH:MM format validation
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
),

-- Data quality validation and cleansing
cleansed_participants AS (
    SELECT 
        p.PARTICIPANT_ID,
        p.MEETING_ID,
        p.USER_ID,
        p.JOIN_TIME,
        p.LEAVE_TIME,
        p.LOAD_TIMESTAMP,
        p.UPDATE_TIMESTAMP,
        p.SOURCE_SYSTEM,
        
        -- Enhanced data quality score calculation including timestamp format compliance
        CASE 
            WHEN p.PARTICIPANT_ID IS NULL THEN 0
            WHEN p.MEETING_ID IS NULL THEN 20
            WHEN p.USER_ID IS NULL THEN 30
            WHEN p.JOIN_TIME IS NULL OR p.LEAVE_TIME IS NULL THEN 40
            WHEN p.LEAVE_TIME <= p.JOIN_TIME THEN 50
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Enhanced validation status including timestamp format validation
        CASE 
            WHEN p.PARTICIPANT_ID IS NULL OR p.MEETING_ID IS NULL OR p.USER_ID IS NULL THEN 'FAILED'
            WHEN p.JOIN_TIME IS NULL OR p.LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN p.LEAVE_TIME <= p.JOIN_TIME THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_processed p
),

-- Remove duplicates keeping the latest record
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_participants
    WHERE PARTICIPANT_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND JOIN_TIME IS NOT NULL
      AND LEAVE_TIME IS NOT NULL
      AND LEAVE_TIME > JOIN_TIME
)

-- Final select with additional Silver layer metadata
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
WHERE rn = 1
