{{ config(
    materialized='table'
) }}

-- Silver Layer Meetings Model
-- Transforms bronze meetings data with enrichment and data quality validations

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
),

-- Data Quality Validation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Temporal validation
        CASE 
            WHEN END_TIME < START_TIME THEN 'INVALID_TIME_SEQUENCE'
            WHEN START_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN 'FUTURE_START_TIME'
            ELSE 'VALID'
        END AS TEMPORAL_QUALITY_FLAG,
        
        -- Duration validation
        CASE 
            WHEN DURATION_MINUTES < 0 THEN 'NEGATIVE_DURATION'
            WHEN DURATION_MINUTES > 1440 THEN 'EXCESSIVE_DURATION'
            ELSE 'VALID'
        END AS DURATION_QUALITY_FLAG,
        
        -- Host validation
        CASE 
            WHEN HOST_ID IS NULL THEN 'MISSING_HOST'
            ELSE 'VALID'
        END AS HOST_QUALITY_FLAG
        
    FROM bronze_meetings
),

-- Deduplication Layer
deduped_meetings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
    WHERE HOST_QUALITY_FLAG != 'MISSING_HOST'  -- Block records with missing host
),

-- Participant count calculation
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS PARTICIPANT_COUNT
    FROM {{ source('bronze', 'bz_participants') }}
    GROUP BY MEETING_ID
),

-- Final transformation
transformed_meetings AS (
    SELECT 
        -- Primary identifiers
        m.MEETING_ID,
        m.HOST_ID,
        
        -- Standardized business columns
        TRIM(m.MEETING_TOPIC) AS MEETING_TOPIC,
        
        -- Meeting type derivation
        CASE 
            WHEN m.DURATION_MINUTES <= 5 THEN 'Instant'
            WHEN m.DURATION_MINUTES BETWEEN 6 AND 60 THEN 'Scheduled'
            WHEN m.DURATION_MINUTES > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS MEETING_TYPE,
        
        -- Corrected timestamps
        m.START_TIME,
        CASE 
            WHEN m.END_TIME < m.START_TIME THEN m.START_TIME + (m.DURATION_MINUTES * INTERVAL '1' MINUTE)
            ELSE m.END_TIME
        END AS END_TIME,
        
        -- Corrected duration
        CASE 
            WHEN m.DURATION_MINUTES < 0 THEN ABS(m.DURATION_MINUTES)
            WHEN m.DURATION_MINUTES < 0 AND m.START_TIME IS NOT NULL AND m.END_TIME IS NOT NULL 
            THEN DATEDIFF('minute', m.START_TIME, m.END_TIME)
            ELSE m.DURATION_MINUTES
        END AS DURATION_MINUTES,
        
        -- Host name (simplified - using HOST_ID as placeholder)
        COALESCE(m.HOST_ID, 'Unknown Host') AS HOST_NAME,
        
        -- Meeting status derivation
        CASE 
            WHEN m.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN m.START_TIME <= CURRENT_TIMESTAMP() AND m.END_TIME >= CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN m.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Unknown'
        END AS MEETING_STATUS,
        
        -- Recording status (derived from topic keywords)
        CASE 
            WHEN LOWER(m.MEETING_TOPIC) LIKE '%record%' OR LOWER(m.MEETING_TOPIC) LIKE '%recording%' THEN 'Yes'
            ELSE 'No'
        END AS RECORDING_STATUS,
        
        -- Participant count
        COALESCE(pc.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        
        -- Metadata columns
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        
        -- Data quality score
        CASE 
            WHEN m.TEMPORAL_QUALITY_FLAG = 'VALID' 
                 AND m.DURATION_QUALITY_FLAG = 'VALID' 
                 AND m.HOST_QUALITY_FLAG = 'VALID' 
            THEN 1.00
            WHEN m.HOST_QUALITY_FLAG = 'VALID' 
                 AND (m.TEMPORAL_QUALITY_FLAG != 'VALID' OR m.DURATION_QUALITY_FLAG != 'VALID')
            THEN 0.75
            ELSE 0.50
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        DATE(m.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(m.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM deduped_meetings m
    LEFT JOIN participant_counts pc ON m.MEETING_ID = pc.MEETING_ID
    WHERE m.rn = 1
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
FROM transformed_meetings
WHERE DATA_QUALITY_SCORE >= 0.50  -- Only allow records with acceptable quality
