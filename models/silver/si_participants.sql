{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, PIPELINE_RUN_ID, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, PROCESSED_BY, PROCESSING_MODE, EXECUTION_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', UUID_STRING(), 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 'INCREMENTAL', 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_ETL_PROCESS' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE TARGET_TABLE = 'SI_PARTICIPANTS' AND EXECUTION_STATUS = 'STARTED' AND DATE(EXECUTION_START_TIME) = CURRENT_DATE() AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Participants transformation with data quality checks
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
      AND TRIM(PARTICIPANT_ID) != ''
      AND JOIN_TIME IS NOT NULL
),

validated_participants AS (
    SELECT 
        bp.PARTICIPANT_ID,
        bp.MEETING_ID,
        bp.USER_ID,
        bp.JOIN_TIME,
        bp.LEAVE_TIME,
        -- Calculate attendance duration
        CASE 
            WHEN bp.LEAVE_TIME IS NOT NULL AND bp.JOIN_TIME IS NOT NULL 
            THEN GREATEST(0, DATEDIFF('minute', bp.JOIN_TIME, bp.LEAVE_TIME))
            ELSE NULL
        END AS ATTENDANCE_DURATION,
        DATE(bp.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bp.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        bp.SOURCE_SYSTEM,
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY bp.PARTICIPANT_ID ORDER BY bp.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_participants bp
    INNER JOIN {{ ref('si_meetings') }} m ON bp.MEETING_ID = m.MEETING_ID
    LEFT JOIN {{ ref('si_users') }} u ON bp.USER_ID = u.USER_ID
    WHERE bp.JOIN_TIME >= m.START_TIME
      AND (bp.LEAVE_TIME IS NULL OR bp.LEAVE_TIME <= m.END_TIME)
      AND (bp.LEAVE_TIME IS NULL OR bp.LEAVE_TIME >= bp.JOIN_TIME)
),

deduped_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        ATTENDANCE_DURATION,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_participants
    WHERE rn = 1
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    ATTENDANCE_DURATION,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_participants
