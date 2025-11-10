{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_PARTICIPANTS' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Silver layer transformation for Participants table
-- Applies data quality checks, referential integrity, and time boundary validation

WITH bronze_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        TRY_TO_TIMESTAMP(JOIN_TIME) AS JOIN_TIME,
        TRY_TO_TIMESTAMP(LEAVE_TIME) AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
),

-- Get meeting boundaries for validation
meeting_boundaries AS (
    SELECT 
        MEETING_ID,
        START_TIME,
        END_TIME
    FROM {{ ref('SI_MEETINGS') }}
),

-- Data quality validation and cleansing
cleansed_participants AS (
    SELECT 
        bp.PARTICIPANT_ID,
        bp.MEETING_ID,
        bp.USER_ID,
        bp.JOIN_TIME,
        bp.LEAVE_TIME,
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        bp.SOURCE_SYSTEM,
        mb.START_TIME AS meeting_start,
        mb.END_TIME AS meeting_end,
        -- Data quality scoring
        CASE 
            WHEN bp.PARTICIPANT_ID IS NULL THEN 0
            WHEN bp.MEETING_ID IS NULL OR bp.USER_ID IS NULL THEN 20
            WHEN bp.JOIN_TIME IS NULL OR bp.LEAVE_TIME IS NULL THEN 30
            WHEN bp.LEAVE_TIME <= bp.JOIN_TIME THEN 40
            WHEN mb.MEETING_ID IS NULL THEN 50
            WHEN mb.START_TIME IS NOT NULL AND mb.END_TIME IS NOT NULL AND (bp.JOIN_TIME < mb.START_TIME OR bp.LEAVE_TIME > mb.END_TIME) THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        -- Validation status
        CASE 
            WHEN bp.PARTICIPANT_ID IS NULL OR bp.MEETING_ID IS NULL OR bp.USER_ID IS NULL THEN 'FAILED'
            WHEN bp.JOIN_TIME IS NULL OR bp.LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN bp.LEAVE_TIME <= bp.JOIN_TIME THEN 'FAILED'
            WHEN mb.MEETING_ID IS NULL THEN 'FAILED'
            WHEN mb.START_TIME IS NOT NULL AND mb.END_TIME IS NOT NULL AND (bp.JOIN_TIME < mb.START_TIME OR bp.LEAVE_TIME > mb.END_TIME) THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_participants bp
    LEFT JOIN meeting_boundaries mb ON bp.MEETING_ID = mb.MEETING_ID
),

-- Remove duplicates keeping the latest record
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_participants
    WHERE PARTICIPANT_ID IS NOT NULL
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
WHERE rn = 1
    AND VALIDATION_STATUS != 'FAILED'
