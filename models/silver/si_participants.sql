{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Participants Table
-- Purpose: Clean and standardized meeting participants with MM/DD/YYYY format handling
-- Source: Bronze BZ_PARTICIPANTS table

WITH source_data AS (
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

timestamp_cleaned AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Handle MM/DD/YYYY HH:MM format conversion
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            JOIN_TIME
        ) AS CLEAN_JOIN_TIME,
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            LEAVE_TIME
        ) AS CLEAN_LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
),

validated_data AS (
    SELECT 
        p.PARTICIPANT_ID,
        p.MEETING_ID,
        p.USER_ID,
        p.CLEAN_JOIN_TIME AS JOIN_TIME,
        p.CLEAN_LEAVE_TIME AS LEAVE_TIME,
        p.LOAD_TIMESTAMP,
        p.UPDATE_TIMESTAMP,
        p.SOURCE_SYSTEM,
        DATE(p.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(p.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        -- Data Quality Score
        CASE 
            WHEN p.PARTICIPANT_ID IS NOT NULL 
                AND p.MEETING_ID IS NOT NULL 
                AND p.USER_ID IS NOT NULL 
                AND p.CLEAN_JOIN_TIME IS NOT NULL 
                AND p.CLEAN_LEAVE_TIME IS NOT NULL
                AND p.CLEAN_LEAVE_TIME > p.CLEAN_JOIN_TIME
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
                AND p.CLEAN_JOIN_TIME IS NOT NULL 
                AND p.CLEAN_LEAVE_TIME IS NOT NULL
                AND p.CLEAN_LEAVE_TIME > p.CLEAN_JOIN_TIME
            THEN 'PASSED'
            WHEN p.PARTICIPANT_ID IS NOT NULL AND p.MEETING_ID IS NOT NULL AND p.USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM timestamp_cleaned p
),

deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_data
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
FROM deduped_data
WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
