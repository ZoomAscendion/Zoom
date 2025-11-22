{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_PARTICIPANTS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Participants table with enhanced timestamp parsing */
WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_PARTICIPANTS') }}
),

/* Clean and validate participants data */
validated_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        /* Enhanced timestamp parsing for multiple formats */
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(JOIN_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING)
        ) AS CLEAN_JOIN_TIME,
        
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'DD/MM/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REGEXP_REPLACE(LEAVE_TIME::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING)
        ) AS CLEAN_LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        /* Row number for deduplication */
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC NULLS LAST) AS rn
    FROM bronze_participants
    WHERE PARTICIPANT_ID IS NOT NULL
),

/* Apply business rules and calculate data quality */
final_participants AS (
    SELECT 
        *,
        /* Data quality score calculation */
        CASE 
            WHEN PARTICIPANT_ID IS NULL THEN 0
            WHEN MEETING_ID IS NULL OR USER_ID IS NULL THEN 20
            WHEN CLEAN_JOIN_TIME IS NULL OR CLEAN_LEAVE_TIME IS NULL THEN 40
            WHEN CLEAN_LEAVE_TIME <= CLEAN_JOIN_TIME THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN PARTICIPANT_ID IS NULL OR MEETING_ID IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN CLEAN_JOIN_TIME IS NULL OR CLEAN_LEAVE_TIME IS NULL THEN 'FAILED'
            WHEN CLEAN_LEAVE_TIME <= CLEAN_JOIN_TIME THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM validated_participants
    WHERE rn = 1
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    CLEAN_JOIN_TIME AS JOIN_TIME,
    CLEAN_LEAVE_TIME AS LEAVE_TIME,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM final_participants
WHERE VALIDATION_STATUS != 'FAILED'
