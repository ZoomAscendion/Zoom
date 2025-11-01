{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_PARTICIPANTS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_PARTICIPANTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM', 'PROD', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, RECORDS_PROCESSED, RECORDS_INSERTED, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_PARTICIPANTS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_PARTICIPANTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'SUCCESS', 'DBT_SYSTEM', 'PROD', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'Silver Layer Pipeline' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Participants Table
-- Transforms participant attendance data with calculated metrics and role assignments

WITH bronze_participants AS (
    SELECT 
        bp.PARTICIPANT_ID,
        bp.MEETING_ID,
        bp.USER_ID,
        bp.JOIN_TIME,
        bp.LEAVE_TIME,
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        bp.SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_participants') }} bp
    WHERE bp.PARTICIPANT_ID IS NOT NULL
      AND bp.MEETING_ID IS NOT NULL
      AND bp.USER_ID IS NOT NULL
      AND bp.JOIN_TIME IS NOT NULL
),

-- Data Quality and Cleansing Layer
cleansed_participants AS (
    SELECT 
        -- Primary Keys
        TRIM(bp.PARTICIPANT_ID) AS PARTICIPANT_ID,
        TRIM(bp.MEETING_ID) AS MEETING_ID,
        TRIM(bp.USER_ID) AS USER_ID,
        
        -- Validated Timestamps
        bp.JOIN_TIME,
        CASE 
            WHEN bp.LEAVE_TIME >= bp.JOIN_TIME THEN bp.LEAVE_TIME
            WHEN bp.LEAVE_TIME IS NULL THEN DATEADD('hour', 2, bp.JOIN_TIME)  -- Default 2 hour session
            ELSE bp.JOIN_TIME  -- Invalid leave time, default to join time
        END AS LEAVE_TIME,
        
        -- Calculated Attendance Duration
        CASE 
            WHEN bp.LEAVE_TIME >= bp.JOIN_TIME 
            THEN DATEDIFF('minute', bp.JOIN_TIME, bp.LEAVE_TIME)
            WHEN bp.LEAVE_TIME IS NULL 
            THEN DATEDIFF('minute', bp.JOIN_TIME, DATEADD('hour', 2, bp.JOIN_TIME))
            ELSE 0
        END AS ATTENDANCE_DURATION,
        
        -- Derive Participant Role (simplified logic)
        CASE 
            WHEN bp.USER_ID IN (
                SELECT DISTINCT HOST_ID 
                FROM {{ source('bronze', 'bz_meetings') }} 
                WHERE MEETING_ID = bp.MEETING_ID
            ) THEN 'Host'
            WHEN DATEDIFF('minute', bp.JOIN_TIME, COALESCE(bp.LEAVE_TIME, CURRENT_TIMESTAMP())) > 60 
            THEN 'Participant'
            ELSE 'Observer'
        END AS PARTICIPANT_ROLE,
        
        -- Connection Quality (derived from attendance duration)
        CASE 
            WHEN DATEDIFF('minute', bp.JOIN_TIME, COALESCE(bp.LEAVE_TIME, CURRENT_TIMESTAMP())) > 120 THEN 'Excellent'
            WHEN DATEDIFF('minute', bp.JOIN_TIME, COALESCE(bp.LEAVE_TIME, CURRENT_TIMESTAMP())) > 60 THEN 'Good'
            WHEN DATEDIFF('minute', bp.JOIN_TIME, COALESCE(bp.LEAVE_TIME, CURRENT_TIMESTAMP())) > 30 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        -- Metadata Columns
        bp.LOAD_TIMESTAMP,
        bp.UPDATE_TIMESTAMP,
        bp.SOURCE_SYSTEM,
        
        -- Data Quality Score Calculation
        (
            CASE WHEN bp.PARTICIPANT_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bp.MEETING_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bp.USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN bp.JOIN_TIME IS NOT NULL THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(bp.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bp.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM bronze_participants bp
),

-- Deduplication Layer
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_participants
)

-- Final Select with Data Quality Filters
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
  AND DATA_QUALITY_SCORE >= 0.75  -- Minimum quality threshold
  AND PARTICIPANT_ID IS NOT NULL
  AND MEETING_ID IS NOT NULL
  AND USER_ID IS NOT NULL
