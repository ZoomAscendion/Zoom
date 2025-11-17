{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_START_TIME, EXECUTED_BY, LOAD_TIMESTAMP) SELECT 'SI_PARTICIPANTS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT 'SI_PARTICIPANTS', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver Layer Participants Table
-- Purpose: Clean and standardized meeting participants and their session details
-- Transformation: Bronze BZ_PARTICIPANTS -> Silver SI_PARTICIPANTS

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
    WHERE PARTICIPANT_ID IS NOT NULL
),

timestamp_cleaning AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Handle MM/DD/YYYY HH:MM format
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE JOIN_TIME
        END AS JOIN_TIME,
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

data_quality_checks AS (
    SELECT 
        p.*,
        -- Session time validation
        CASE 
            WHEN p.JOIN_TIME IS NOT NULL AND p.LEAVE_TIME IS NOT NULL AND p.LEAVE_TIME > p.JOIN_TIME THEN 1
            ELSE 0
        END AS session_time_valid,
        
        -- Meeting boundary validation
        CASE 
            WHEN m.MEETING_ID IS NOT NULL AND p.JOIN_TIME >= m.START_TIME AND p.LEAVE_TIME <= m.END_TIME THEN 1
            ELSE 0
        END AS meeting_boundary_valid,
        
        -- Calculate data quality score
        CASE 
            WHEN p.PARTICIPANT_ID IS NOT NULL AND p.MEETING_ID IS NOT NULL AND p.USER_ID IS NOT NULL 
                 AND p.JOIN_TIME IS NOT NULL AND p.LEAVE_TIME IS NOT NULL THEN
                CASE 
                    WHEN p.LEAVE_TIME > p.JOIN_TIME AND m.MEETING_ID IS NOT NULL 
                         AND p.JOIN_TIME >= m.START_TIME AND p.LEAVE_TIME <= m.END_TIME THEN 100
                    WHEN p.LEAVE_TIME > p.JOIN_TIME AND m.MEETING_ID IS NOT NULL THEN 80
                    WHEN p.LEAVE_TIME > p.JOIN_TIME THEN 60
                    ELSE 40
                END
            ELSE 0
        END AS data_quality_score
    FROM timestamp_cleaning p
    LEFT JOIN {{ ref('SI_MEETINGS') }} m ON p.MEETING_ID = m.MEETING_ID
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

cleaned_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 80 THEN 'PASSED'
            WHEN data_quality_score >= 50 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
      AND PARTICIPANT_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND JOIN_TIME IS NOT NULL
      AND LEAVE_TIME IS NOT NULL
      AND LEAVE_TIME > JOIN_TIME
)

SELECT * FROM cleaned_participants
