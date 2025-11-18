{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver layer transformation for Participants table with timestamp format handling */
WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
),

timestamp_cleaning AS (
    SELECT 
        *,
        /* Enhanced timestamp parsing for multiple formats */
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME)
        ) AS cleaned_join_time,
        
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME)
        ) AS cleaned_leave_time
    FROM bronze_participants
),

data_quality_checks AS (
    SELECT 
        *,
        /* Validate participant session logic */
        CASE 
            WHEN cleaned_leave_time <= cleaned_join_time THEN 'INVALID_SESSION_TIME'
            ELSE 'VALID'
        END AS session_validation,
        
        /* Data quality score calculation */
        (
            CASE WHEN PARTICIPANT_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN cleaned_join_time IS NOT NULL AND cleaned_leave_time IS NOT NULL AND cleaned_leave_time > cleaned_join_time THEN 25 ELSE 0 END
        ) AS data_quality_score,
        
        /* Validation status */
        CASE 
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN cleaned_join_time IS NULL OR cleaned_leave_time IS NULL THEN 'FAILED'
            WHEN cleaned_leave_time <= cleaned_join_time THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM timestamp_cleaning
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE PARTICIPANT_ID IS NOT NULL
),

final_transformation AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        cleaned_join_time AS JOIN_TIME,
        cleaned_leave_time AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
    AND validation_status != 'FAILED'
)

SELECT * FROM final_transformation
