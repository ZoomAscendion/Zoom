{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('si_audit_log') }} (
            EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, 
            SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP
        )
        VALUES (
            '{{ invocation_id }}', 
            'si_participants', 
            CURRENT_TIMESTAMP(), 
            'RUNNING', 
            'BRONZE.BZ_PARTICIPANTS', 
            'SILVER.SI_PARTICIPANTS', 
            'DBT_SILVER_PIPELINE', 
            CURRENT_TIMESTAMP()
        )",
    post_hook="
        UPDATE {{ ref('si_audit_log') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }})
        WHERE EXECUTION_ID = '{{ invocation_id }}' 
        AND TARGET_TABLE = 'SILVER.SI_PARTICIPANTS'"
) }}

-- Silver layer participants table with MM/DD/YYYY timestamp format handling
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
      AND MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
),

cleansed_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        -- Handle MM/DD/YYYY HH:MM format in JOIN_TIME
        COALESCE(
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REPLACE(JOIN_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
        ) AS JOIN_TIME,
        -- Handle MM/DD/YYYY HH:MM format in LEAVE_TIME
        COALESCE(
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'),
            TRY_TO_TIMESTAMP(REPLACE(LEAVE_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')
        ) AS LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_participants
),

validated_participants AS (
    SELECT 
        bp.PARTICIPANT_ID,
        bp.MEETING_ID,
        bp.USER_ID,
        bp.JOIN_TIME,
        bp.LEAVE_TIME,
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        bp.SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(bp.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bp.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality scoring
        CASE 
            WHEN bp.JOIN_TIME IS NOT NULL AND bp.LEAVE_TIME IS NOT NULL 
                 AND bp.LEAVE_TIME > bp.JOIN_TIME 
                 AND m.MEETING_ID IS NOT NULL 
                 AND u.USER_ID IS NOT NULL THEN 100
            WHEN bp.JOIN_TIME IS NOT NULL AND bp.LEAVE_TIME IS NOT NULL 
                 AND bp.LEAVE_TIME > bp.JOIN_TIME THEN 80
            WHEN bp.JOIN_TIME IS NOT NULL AND bp.LEAVE_TIME IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN bp.JOIN_TIME IS NOT NULL AND bp.LEAVE_TIME IS NOT NULL 
                 AND bp.LEAVE_TIME > bp.JOIN_TIME 
                 AND m.MEETING_ID IS NOT NULL 
                 AND u.USER_ID IS NOT NULL THEN 'PASSED'
            WHEN bp.LEAVE_TIME <= bp.JOIN_TIME THEN 'FAILED'
            WHEN m.MEETING_ID IS NULL OR u.USER_ID IS NULL THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_participants bp
    LEFT JOIN {{ ref('si_meetings') }} m ON bp.MEETING_ID = m.MEETING_ID
    LEFT JOIN {{ ref('si_users') }} u ON bp.USER_ID = u.USER_ID
    WHERE bp.rn = 1
      AND bp.JOIN_TIME IS NOT NULL
      AND bp.LEAVE_TIME IS NOT NULL
      AND bp.LEAVE_TIME > bp.JOIN_TIME  -- Business logic validation
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
FROM validated_participants
