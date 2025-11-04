{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ target.schema }}.SI_PIPELINE_AUDIT (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, EXECUTED_BY, EXECUTION_ENVIRONMENT) VALUES (GENERATE_UUID(), 'SI_PARTICIPANTS_TRANSFORM', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_PARTICIPANTS', 'DBT_SYSTEM', 'PRODUCTION')",
    post_hook="UPDATE {{ target.schema }}.SI_PIPELINE_AUDIT SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_PARTICIPANTS_TRANSFORM' AND STATUS = 'RUNNING'"
) }}

-- Silver Layer Participants Transformation
-- Source: Bronze.BZ_PARTICIPANTS
-- Target: Silver.SI_PARTICIPANTS
-- Description: Clean, validate and calculate participant attendance metrics

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
    FROM {{ ref('bz_participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
      AND MEETING_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND JOIN_TIME IS NOT NULL
),

-- Data Quality Validation and Cleansing
validated_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Validate join time
        CASE 
            WHEN JOIN_TIME > CURRENT_TIMESTAMP() THEN CURRENT_TIMESTAMP()
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        -- Validate and fix leave time
        CASE 
            WHEN LEAVE_TIME IS NULL THEN DATEADD('minute', 30, JOIN_TIME)  -- Default 30 min session
            WHEN LEAVE_TIME < JOIN_TIME THEN DATEADD('minute', 5, JOIN_TIME)  -- Minimum 5 min session
            WHEN LEAVE_TIME > CURRENT_TIMESTAMP() THEN CURRENT_TIMESTAMP()
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        -- Calculate attendance duration
        DATEDIFF('minute', 
            JOIN_TIME,
            CASE 
                WHEN LEAVE_TIME IS NULL THEN DATEADD('minute', 30, JOIN_TIME)
                WHEN LEAVE_TIME < JOIN_TIME THEN DATEADD('minute', 5, JOIN_TIME)
                WHEN LEAVE_TIME > CURRENT_TIMESTAMP() THEN CURRENT_TIMESTAMP()
                ELSE LEAVE_TIME
            END
        ) AS ATTENDANCE_DURATION,
        
        -- Derive participant role (simplified logic)
        CASE 
            WHEN ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY JOIN_TIME) = 1 THEN 'Host'
            ELSE 'Participant'
        END AS PARTICIPANT_ROLE,
        
        -- Derive connection quality from attendance duration
        CASE 
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 30, JOIN_TIME))) >= 45 THEN 'Excellent'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 30, JOIN_TIME))) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 30, JOIN_TIME))) >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN PARTICIPANT_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN JOIN_TIME IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_participants
)

-- Final selection with deduplication
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
FROM validated_participants
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.75  -- Only include records with good quality
  AND ATTENDANCE_DURATION > 0     -- Only include valid attendance records
