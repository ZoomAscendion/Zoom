{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Participants Table
-- Transforms and cleanses participant data from Bronze layer
-- Handles MM/DD/YYYY HH:MM format conversion and validation

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
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
),

timestamp_converted AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Enhanced MM/DD/YYYY HH:MM Format Conversion for JOIN_TIME
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$' THEN 
                CASE 
                    WHEN TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NOT NULL THEN
                        TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
                    ELSE JOIN_TIME
                END
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        -- Enhanced MM/DD/YYYY HH:MM Format Conversion for LEAVE_TIME
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$' THEN 
                CASE 
                    WHEN TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NOT NULL THEN
                        TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
                    ELSE LEAVE_TIME
                END
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
),

validated_participants AS (
    SELECT 
        p.*,
        -- Validate participant session logic
        CASE 
            WHEN p.LEAVE_TIME > p.JOIN_TIME 
                AND p.JOIN_TIME IS NOT NULL 
                AND p.LEAVE_TIME IS NOT NULL
            THEN TRUE
            ELSE FALSE
        END AS is_valid_session,
        
        -- Data Quality Score
        CASE 
            WHEN p.PARTICIPANT_ID IS NOT NULL 
                AND p.MEETING_ID IS NOT NULL 
                AND p.USER_ID IS NOT NULL 
                AND p.JOIN_TIME IS NOT NULL 
                AND p.LEAVE_TIME IS NOT NULL
                AND p.LEAVE_TIME > p.JOIN_TIME
            THEN 100
            WHEN p.PARTICIPANT_ID IS NOT NULL AND p.MEETING_ID IS NOT NULL AND p.USER_ID IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN p.PARTICIPANT_ID IS NOT NULL 
                AND p.MEETING_ID IS NOT NULL 
                AND p.USER_ID IS NOT NULL 
                AND p.JOIN_TIME IS NOT NULL 
                AND p.LEAVE_TIME IS NOT NULL
                AND p.LEAVE_TIME > p.JOIN_TIME
            THEN 'PASSED'
            WHEN p.PARTICIPANT_ID IS NOT NULL AND p.MEETING_ID IS NOT NULL AND p.USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM timestamp_converted p
),

deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_participants
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
    AND is_valid_session = TRUE
