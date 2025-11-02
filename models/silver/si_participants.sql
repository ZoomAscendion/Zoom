{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT 'EXEC_PARTICIPANTS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_PARTICIPANTS_PIPELINE', CURRENT_TIMESTAMP(), 'In Progress', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_SILVER_PIPELINE', 'PROD', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AUDIT_LOG')",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT 'EXEC_PARTICIPANTS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_PARTICIPANTS_PIPELINE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'Success', COUNT(*), COUNT(*), 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_SILVER_PIPELINE', 'PROD', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' FROM {{ this }} WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AUDIT_LOG')"
) }}

-- Silver Layer Participants Model
-- Transforms bronze participants data with attendance calculations and validations

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
),

-- Data Quality Validation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Temporal validation
        CASE 
            WHEN LEAVE_TIME < JOIN_TIME THEN 'INVALID_TIME_SEQUENCE'
            WHEN JOIN_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN 'FUTURE_JOIN_TIME'
            WHEN LEAVE_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN 'FUTURE_LEAVE_TIME'
            ELSE 'VALID'
        END AS TEMPORAL_QUALITY_FLAG,
        
        -- Referential integrity check
        CASE 
            WHEN MEETING_ID IS NULL THEN 'MISSING_MEETING_REF'
            WHEN USER_ID IS NULL THEN 'MISSING_USER_REF'
            ELSE 'VALID'
        END AS REFERENCE_QUALITY_FLAG
        
    FROM bronze_participants
),

-- Deduplication Layer
deduped_participants AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
    WHERE REFERENCE_QUALITY_FLAG = 'VALID'  -- Block records with missing references
),

-- Referential integrity validation
validated_participants AS (
    SELECT p.*
    FROM deduped_participants p
    INNER JOIN {{ ref('si_meetings') }} m ON p.MEETING_ID = m.MEETING_ID
    INNER JOIN {{ ref('si_users') }} u ON p.USER_ID = u.USER_ID
    WHERE p.rn = 1
),

-- Final transformation
transformed_participants AS (
    SELECT 
        -- Primary identifiers
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Corrected timestamps
        JOIN_TIME,
        CASE 
            WHEN LEAVE_TIME < JOIN_TIME THEN JOIN_TIME + INTERVAL '30' MINUTE
            WHEN LEAVE_TIME IS NULL THEN JOIN_TIME + INTERVAL '30' MINUTE
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        -- Calculated attendance duration
        CASE 
            WHEN LEAVE_TIME IS NOT NULL AND LEAVE_TIME >= JOIN_TIME 
            THEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
            WHEN LEAVE_TIME IS NULL 
            THEN 30  -- Default 30 minutes for missing leave time
            ELSE 0
        END AS ATTENDANCE_DURATION,
        
        -- Participant role derivation (simplified logic)
        CASE 
            WHEN EXISTS (SELECT 1 FROM {{ ref('si_meetings') }} m WHERE m.MEETING_ID = p.MEETING_ID AND m.HOST_ID = p.USER_ID)
            THEN 'Host'
            ELSE 'Participant'
        END AS PARTICIPANT_ROLE,
        
        -- Connection quality derivation based on attendance duration
        CASE 
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, JOIN_TIME + INTERVAL '30' MINUTE)) >= 45 THEN 'Excellent'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, JOIN_TIME + INTERVAL '30' MINUTE)) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, JOIN_TIME + INTERVAL '30' MINUTE)) >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score
        CASE 
            WHEN TEMPORAL_QUALITY_FLAG = 'VALID' 
                 AND REFERENCE_QUALITY_FLAG = 'VALID' 
            THEN 1.00
            WHEN REFERENCE_QUALITY_FLAG = 'VALID' 
                 AND TEMPORAL_QUALITY_FLAG != 'VALID'
            THEN 0.75
            ELSE 0.50
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM validated_participants p
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
FROM transformed_participants
WHERE DATA_QUALITY_SCORE >= 0.50  -- Only allow records with acceptable quality
