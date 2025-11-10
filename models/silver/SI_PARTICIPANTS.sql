{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Participants table
-- Applies data quality checks, referential integrity, and time boundary validation

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

-- Get meeting boundaries for validation
meeting_boundaries AS (
    SELECT 
        MEETING_ID AS mtg_meeting_id,
        START_TIME AS mtg_start_time,
        END_TIME AS mtg_end_time
    FROM {{ ref('SI_MEETINGS') }}
),

-- Join with meeting data for boundary validation
participants_with_meetings AS (
    SELECT 
        bp.*,
        mb.mtg_start_time,
        mb.mtg_end_time
    FROM bronze_participants bp
    LEFT JOIN meeting_boundaries mb ON bp.MEETING_ID = mb.mtg_meeting_id
),

-- Data quality validation and scoring
validated_participants AS (
    SELECT 
        *,
        -- Data quality score calculation (0-100)
        CASE 
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL OR USER_ID IS NULL THEN 0
            WHEN JOIN_TIME IS NULL OR LEAVE_TIME IS NULL THEN 20
            WHEN LEAVE_TIME <= JOIN_TIME THEN 30
            WHEN mtg_start_time IS NULL THEN 40  -- Meeting doesn't exist
            WHEN JOIN_TIME < mtg_start_time OR LEAVE_TIME > mtg_end_time THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN JOIN_TIME IS NULL OR LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN LEAVE_TIME <= JOIN_TIME THEN 'FAILED'
            WHEN mtg_start_time IS NULL THEN 'FAILED'  -- Meeting doesn't exist
            WHEN JOIN_TIME < mtg_start_time OR LEAVE_TIME > mtg_end_time THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM participants_with_meetings
),

-- Remove duplicates keeping latest record
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_participants
    WHERE VALIDATION_STATUS != 'FAILED'
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
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
WHERE rn = 1
