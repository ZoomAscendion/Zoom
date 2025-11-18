{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY, ERROR_DESCRIPTION) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', 'Starting SI_PARTICIPANTS transformation' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY, ERROR_DESCRIPTION) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', 'Completed SI_PARTICIPANTS transformation with ' || (SELECT COUNT(*) FROM {{ this }}) || ' records' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- SI_PARTICIPANTS: Silver layer transformation from Bronze BZ_PARTICIPANTS
-- Description: Stores cleaned and standardized meeting participants with enhanced timestamp handling
-- Implements MM/DD/YYYY HH:MM format validation and conversion

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

cleaned_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Enhanced timestamp handling for multiple formats
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(JOIN_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING)
        ) AS JOIN_TIME,
        -- Enhanced timestamp handling for multiple formats
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(LEAVE_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING)
        ) AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_participants
),

validated_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Calculate data quality score
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
        -- Set validation status
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND JOIN_TIME IS NOT NULL 
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME > JOIN_TIME
            THEN 'PASSED'
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_participants
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
FROM validated_participants
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
