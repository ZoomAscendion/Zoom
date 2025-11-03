{{
    config(
        materialized='table',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Participants Transformation
-- Transforms Bronze layer participant data with attendance calculations

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

-- Data Quality Validations and Cleansing
participants_cleaned AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Validate join time
        CASE 
            WHEN JOIN_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN CURRENT_TIMESTAMP()
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        -- Validate leave time and ensure it's after join time
        CASE 
            WHEN LEAVE_TIME IS NULL THEN JOIN_TIME + INTERVAL '30' MINUTE  -- Default 30 min session
            WHEN LEAVE_TIME < JOIN_TIME THEN JOIN_TIME + INTERVAL '1' MINUTE
            WHEN LEAVE_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN CURRENT_TIMESTAMP()
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_participants
),

-- Calculate attendance metrics
participants_with_metrics AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Calculate attendance duration in minutes
        DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) AS ATTENDANCE_DURATION,
        
        -- Derive participant role (simplified logic)
        CASE 
            WHEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) > 60 THEN 'Host'
            WHEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) > 30 THEN 'Participant'
            ELSE 'Observer'
        END AS PARTICIPANT_ROLE,
        
        -- Derive connection quality from attendance patterns
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
        (
            CASE WHEN PARTICIPANT_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN MEETING_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN JOIN_TIME IS NOT NULL AND LEAVE_TIME IS NOT NULL AND LEAVE_TIME >= JOIN_TIME THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM participants_cleaned
),

-- Remove duplicates keeping the latest record
participants_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM participants_with_metrics
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
FROM participants_deduped
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.75  -- Only allow records with at least 75% data quality
