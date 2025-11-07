{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Participants table
-- Applies data quality checks, time validation, and referential integrity

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

-- Validate participant data
validated_participants AS (
    SELECT 
        bp.*,
        mb.mtg_start_time,
        mb.mtg_end_time,
        
        -- Calculate data quality score
        CASE 
            WHEN bp.PARTICIPANT_ID IS NOT NULL 
                AND bp.MEETING_ID IS NOT NULL 
                AND bp.USER_ID IS NOT NULL 
                AND bp.JOIN_TIME IS NOT NULL 
                AND bp.LEAVE_TIME IS NOT NULL 
                AND bp.LEAVE_TIME > bp.JOIN_TIME
                AND (mb.mtg_start_time IS NULL OR bp.JOIN_TIME >= mb.mtg_start_time)
                AND (mb.mtg_end_time IS NULL OR bp.LEAVE_TIME <= mb.mtg_end_time)
            THEN 100
            WHEN bp.PARTICIPANT_ID IS NOT NULL 
                AND bp.MEETING_ID IS NOT NULL 
                AND bp.USER_ID IS NOT NULL 
                AND bp.JOIN_TIME IS NOT NULL 
                AND bp.LEAVE_TIME IS NOT NULL 
                AND bp.LEAVE_TIME > bp.JOIN_TIME
            THEN 75
            WHEN bp.PARTICIPANT_ID IS NOT NULL 
                AND bp.MEETING_ID IS NOT NULL 
                AND bp.USER_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS data_quality_score,
        
        -- Set validation status
        CASE 
            WHEN bp.PARTICIPANT_ID IS NOT NULL 
                AND bp.MEETING_ID IS NOT NULL 
                AND bp.USER_ID IS NOT NULL 
                AND bp.JOIN_TIME IS NOT NULL 
                AND bp.LEAVE_TIME IS NOT NULL 
                AND bp.LEAVE_TIME > bp.JOIN_TIME
                AND (mb.mtg_start_time IS NULL OR bp.JOIN_TIME >= mb.mtg_start_time)
                AND (mb.mtg_end_time IS NULL OR bp.LEAVE_TIME <= mb.mtg_end_time)
            THEN 'PASSED'
            WHEN bp.PARTICIPANT_ID IS NOT NULL 
                AND bp.MEETING_ID IS NOT NULL 
                AND bp.USER_ID IS NOT NULL 
                AND bp.JOIN_TIME IS NOT NULL 
                AND bp.LEAVE_TIME IS NOT NULL 
                AND bp.LEAVE_TIME > bp.JOIN_TIME
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS validation_status
    FROM bronze_participants bp
    LEFT JOIN meeting_boundaries mb ON bp.MEETING_ID = mb.mtg_meeting_id
),

-- Remove duplicates keeping the latest record
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_participants
    WHERE validation_status IN ('PASSED', 'WARNING')
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
    data_quality_score AS DATA_QUALITY_SCORE,
    validation_status AS VALIDATION_STATUS
FROM deduped_participants
WHERE rn = 1
