{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_PRT'), 'Silver_Participants_ETL', CURRENT_TIMESTAMP(), 'Started', 'BRONZE.BZ_PARTICIPANTS', 'SILVER.SI_PARTICIPANTS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Processing participants data from Bronze to Silver', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_PRT_END'), 'Silver_Participants_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Participants Table Transformation
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

meeting_info AS (
    SELECT 
        MEETING_ID,
        HOST_ID
    FROM {{ ref('si_meetings') }}
),

validated_participants AS (
    SELECT 
        p.PARTICIPANT_ID,
        p.MEETING_ID,
        p.USER_ID,
        
        CASE 
            WHEN p.JOIN_TIME > CURRENT_TIMESTAMP() THEN CURRENT_TIMESTAMP()
            ELSE p.JOIN_TIME
        END AS JOIN_TIME,
        
        CASE 
            WHEN p.LEAVE_TIME IS NULL THEN DATEADD('minute', 30, p.JOIN_TIME)
            WHEN p.LEAVE_TIME < p.JOIN_TIME THEN p.JOIN_TIME
            WHEN p.LEAVE_TIME > CURRENT_TIMESTAMP() THEN CURRENT_TIMESTAMP()
            ELSE p.LEAVE_TIME
        END AS LEAVE_TIME,
        
        DATEDIFF('minute', 
            p.JOIN_TIME, 
            CASE 
                WHEN p.LEAVE_TIME IS NULL THEN DATEADD('minute', 30, p.JOIN_TIME)
                WHEN p.LEAVE_TIME < p.JOIN_TIME THEN p.JOIN_TIME
                ELSE p.LEAVE_TIME
            END
        ) AS ATTENDANCE_DURATION,
        
        CASE 
            WHEN p.USER_ID = m.HOST_ID THEN 'Host'
            ELSE 'Participant'
        END AS PARTICIPANT_ROLE,
        
        CASE 
            WHEN DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, DATEADD('minute', 30, p.JOIN_TIME))) >= 45 THEN 'Excellent'
            WHEN DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, DATEADD('minute', 30, p.JOIN_TIME))) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, DATEADD('minute', 30, p.JOIN_TIME))) >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        p.LOAD_TIMESTAMP,
        p.UPDATE_TIMESTAMP,
        p.SOURCE_SYSTEM,
        
        (
            CASE WHEN p.PARTICIPANT_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN p.MEETING_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN p.USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN p.JOIN_TIME IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(p.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(p.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_participants p
    LEFT JOIN meeting_info m ON p.MEETING_ID = m.MEETING_ID
),

deduped_participants AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_participants
)

SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    ATTENDANCE_DURATION,
    PARTICIPANT_ROLE,
    CONNECTION_QUALITY,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM deduped_participants
WHERE rn = 1
  AND JOIN_TIME IS NOT NULL
  AND ATTENDANCE_DURATION >= 0
  AND DATA_QUALITY_SCORE >= 0.75
