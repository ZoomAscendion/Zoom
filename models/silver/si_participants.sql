{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_PARTICIPANTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_PIPELINE', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, RECORDS_PROCESSED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_PARTICIPANTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)"
) }}

-- Silver Layer Participants Table Transformation
-- Source: Bronze.BZ_PARTICIPANTS

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
),

-- Data Quality Validation and Cleansing
validated_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Validate join time
        CASE 
            WHEN JOIN_TIME > DATEADD('year', 1, CURRENT_TIMESTAMP()) 
            THEN CURRENT_TIMESTAMP()
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        -- Validate and correct leave time
        CASE 
            WHEN LEAVE_TIME IS NULL 
            THEN DATEADD('minute', 60, JOIN_TIME)  -- Default 1 hour session
            WHEN LEAVE_TIME < JOIN_TIME 
            THEN JOIN_TIME
            WHEN LEAVE_TIME > DATEADD('year', 1, CURRENT_TIMESTAMP()) 
            THEN CURRENT_TIMESTAMP()
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_participants
    WHERE PARTICIPANT_ID IS NOT NULL
        AND MEETING_ID IS NOT NULL
        AND USER_ID IS NOT NULL
),

-- Calculate derived fields
final_participants AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Calculate attendance duration
        DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) AS ATTENDANCE_DURATION,
        
        -- Derive participant role (simplified logic)
        'Participant' AS PARTICIPANT_ROLE,
        
        -- Derive connection quality based on attendance duration
        CASE 
            WHEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) >= 45 THEN 'Excellent'
            WHEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND USER_ID IS NOT NULL
                AND JOIN_TIME IS NOT NULL
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME >= JOIN_TIME
            THEN 1.00
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 0.75
            ELSE 0.50
        END AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
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
    PARTICIPANT_ROLE,
    CONNECTION_QUALITY,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM final_participants
