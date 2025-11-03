{{
    config(
        materialized='table',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Meetings Transformation
-- Transforms Bronze layer meeting data with enrichment and validations

WITH bronze_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
),

-- Join with users to get host information
meetings_with_host AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        m.MEETING_TOPIC,
        m.START_TIME,
        m.END_TIME,
        m.DURATION_MINUTES,
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        COALESCE(u.USER_NAME, 'Unknown Host') AS HOST_NAME
    FROM bronze_meetings m
    LEFT JOIN {{ ref('si_users') }} u ON m.HOST_ID = u.USER_ID
),

-- Get participant count from participants table
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE MEETING_ID IS NOT NULL
    GROUP BY MEETING_ID
),

-- Data Quality Validations and Cleansing
meetings_cleaned AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        
        -- Clean and standardize meeting topic
        CASE 
            WHEN m.MEETING_TOPIC IS NULL OR TRIM(m.MEETING_TOPIC) = '' THEN 'Untitled Meeting'
            ELSE TRIM(m.MEETING_TOPIC)
        END AS MEETING_TOPIC,
        
        -- Derive meeting type from duration and other attributes
        CASE 
            WHEN m.DURATION_MINUTES <= 5 THEN 'Instant'
            WHEN m.DURATION_MINUTES BETWEEN 6 AND 60 THEN 'Scheduled'
            WHEN m.DURATION_MINUTES > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Validate and correct timestamps
        CASE 
            WHEN m.START_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' DAY THEN CURRENT_TIMESTAMP()
            ELSE m.START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN m.END_TIME < m.START_TIME THEN m.START_TIME + (m.DURATION_MINUTES * INTERVAL '1' MINUTE)
            WHEN m.END_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' DAY THEN CURRENT_TIMESTAMP()
            ELSE m.END_TIME
        END AS END_TIME,
        
        -- Validate and recalculate duration
        CASE 
            WHEN m.DURATION_MINUTES < 1 THEN 1
            WHEN m.DURATION_MINUTES > 1440 THEN 1440
            ELSE m.DURATION_MINUTES
        END AS DURATION_MINUTES,
        
        m.HOST_NAME,
        
        -- Derive meeting status from timestamps
        CASE 
            WHEN m.END_TIME IS NULL THEN 'Scheduled'
            WHEN m.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN m.START_TIME <= CURRENT_TIMESTAMP() AND m.END_TIME >= CURRENT_TIMESTAMP() THEN 'In Progress'
            ELSE 'Scheduled'
        END AS MEETING_STATUS,
        
        -- Derive recording status (simplified logic)
        CASE 
            WHEN m.DURATION_MINUTES > 30 THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN m.MEETING_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN m.HOST_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN m.START_TIME IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN m.END_TIME IS NOT NULL AND m.END_TIME >= m.START_TIME THEN 0.2 ELSE 0 END +
            CASE WHEN m.DURATION_MINUTES > 0 THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(m.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(m.UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM meetings_with_host m
    LEFT JOIN participant_counts pc ON m.MEETING_ID = pc.MEETING_ID
),

-- Remove duplicates keeping the latest record
meetings_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM meetings_cleaned
)

SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    MEETING_TYPE,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    HOST_NAME,
    MEETING_STATUS,
    RECORDING_STATUS,
    PARTICIPANT_COUNT,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM meetings_deduped
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.60  -- Only allow records with at least 60% data quality
