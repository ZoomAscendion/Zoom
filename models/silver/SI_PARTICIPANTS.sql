{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

/* Silver Participants table with MM/DD/YYYY HH:MM timestamp format handling */

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
        *,
        /* Handle MM/DD/YYYY HH:MM format conversion using macro */
        {{ safe_to_timestamp('JOIN_TIME') }} AS CLEAN_JOIN_TIME,
        {{ safe_to_timestamp('LEAVE_TIME') }} AS CLEAN_LEAVE_TIME
    FROM bronze_participants
),

data_quality_checks AS (
    SELECT 
        p.*,
        /* Data Quality Score Calculation */
        (
            CASE WHEN p.PARTICIPANT_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN p.MEETING_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN p.USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN p.CLEAN_JOIN_TIME IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN p.CLEAN_LEAVE_TIME IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN p.CLEAN_LEAVE_TIME > p.CLEAN_JOIN_TIME THEN 5 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN p.PARTICIPANT_ID IS NULL OR p.MEETING_ID IS NULL OR p.USER_ID IS NULL THEN 'FAILED'
            WHEN p.CLEAN_JOIN_TIME IS NULL OR p.CLEAN_LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN p.CLEAN_LEAVE_TIME <= p.CLEAN_JOIN_TIME THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM timestamp_cleaning p
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    CLEAN_JOIN_TIME AS JOIN_TIME,
    CLEAN_LEAVE_TIME AS LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
