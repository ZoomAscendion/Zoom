{{ config(
    materialized='table',
    pre_hook="INSERT INTO SILVER.SI_AUDIT_LOG (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_PARTICIPANTS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="UPDATE SILVER.SI_AUDIT_LOG SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_SUCCESS = (SELECT COUNT(*) FROM SILVER.SI_PARTICIPANTS), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_PARTICIPANTS' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Silver Layer Participants Table
-- Transforms and cleanses participant data from Bronze layer
-- Applies data quality checks and business rules

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
    FROM BRONZE.BZ_PARTICIPANTS
),

cleansed_participants AS (
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
        DATE(bp.UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_participants bp
    INNER JOIN SILVER.SI_MEETINGS sm ON bp.MEETING_ID = sm.MEETING_ID
    INNER JOIN SILVER.SI_USERS su ON bp.USER_ID = su.USER_ID
    WHERE bp.PARTICIPANT_ID IS NOT NULL
        AND bp.MEETING_ID IS NOT NULL
        AND bp.USER_ID IS NOT NULL
        AND bp.JOIN_TIME IS NOT NULL
        AND bp.LEAVE_TIME IS NOT NULL
        AND bp.LEAVE_TIME > bp.JOIN_TIME
        AND bp.JOIN_TIME >= sm.START_TIME
        AND bp.LEAVE_TIME <= sm.END_TIME
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND JOIN_TIME IS NOT NULL 
                AND LEAVE_TIME IS NOT NULL 
                AND LEAVE_TIME > JOIN_TIME
            THEN 100
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 75
            WHEN PARTICIPANT_ID IS NOT NULL
            THEN 50
            ELSE 25
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
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL 
                AND USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_participants
),

-- Remove duplicates keeping the latest record
deduped_participants AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    ) ranked
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
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
