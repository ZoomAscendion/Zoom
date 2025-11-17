{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_RUN', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this }}' != '{{ ref('SI_Audit_Log') }}'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'COMPLETED', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this }}' != '{{ ref('SI_Audit_Log') }}'"
) }}

-- Silver Participants table transformation from Bronze layer
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
    FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
),

-- Handle MM/DD/YYYY HH:MM format conversion
cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Handle MM/DD/YYYY HH:MM format conversion for JOIN_TIME
        CASE 
            WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_CAST(
                    TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI') AS TIMESTAMP_NTZ(9)
                )
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        -- Handle MM/DD/YYYY HH:MM format conversion for LEAVE_TIME
        CASE 
            WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_CAST(
                    TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI') AS TIMESTAMP_NTZ(9)
                )
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
    WHERE PARTICIPANT_ID IS NOT NULL
),

-- Validate participant session logic
validated_participants AS (
    SELECT 
        p.*,
        
        -- Data quality scoring
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
            WHEN p.PARTICIPANT_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN p.PARTICIPANT_ID IS NULL OR p.MEETING_ID IS NULL OR p.USER_ID IS NULL THEN 'FAILED'
            WHEN p.JOIN_TIME IS NULL OR p.LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN p.LEAVE_TIME <= p.JOIN_TIME THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM cleansed_participants p
),

-- Remove duplicates keeping the latest record
deduped_participants AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
        FROM validated_participants
    )
    WHERE rn = 1
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
WHERE VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
