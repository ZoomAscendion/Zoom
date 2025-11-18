{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'"
) }}

/* Transform Bronze Participants to Silver with timestamp format validation */
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

cleaned_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        /* Enhanced timestamp cleaning with multi-format support */
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME)
        ) AS JOIN_TIME,
        
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME)
        ) AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
    WHERE PARTICIPANT_ID IS NOT NULL
),

validated_participants AS (
    SELECT 
        *,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        /* Data quality score calculation */
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND JOIN_TIME IS NOT NULL 
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME > JOIN_TIME
            THEN 100
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND JOIN_TIME IS NOT NULL 
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME > JOIN_TIME
            THEN 'PASSED'
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL OR USER_ID IS NULL 
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleaned_participants
),

deduped_participants AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
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
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_participants
