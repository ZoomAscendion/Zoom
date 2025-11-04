{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.SI_PIPELINE_AUDIT (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) VALUES (CONCAT('{{ invocation_id }}', '_si_meetings'), 'si_meetings', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.SI_PIPELINE_AUDIT (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) VALUES (CONCAT('{{ invocation_id }}', '_si_meetings'), 'si_meetings', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE())"
) }}

-- Silver Meetings Model - Cleaned and enriched meeting data
-- Transforms Bronze meeting data with calculated metrics and data quality validations

WITH bronze_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'meetings') }}
    WHERE meeting_id IS NOT NULL
),

-- Get host names from users
host_info AS (
    SELECT 
        user_id,
        user_name
    FROM {{ ref('si_users') }}
),

-- Get participant counts
participant_counts AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ source('raw_schema', 'participants') }}
    WHERE meeting_id IS NOT NULL
    GROUP BY meeting_id
),

-- Data Quality Checks and Cleansing
meetings_cleaned AS (
    SELECT 
        m.meeting_id,
        COALESCE(m.host_id, 'UNKNOWN_HOST') AS host_id,
        
        -- Clean and standardize meeting topic
        CASE 
            WHEN m.meeting_topic IS NULL OR TRIM(m.meeting_topic) = '' 
            THEN 'Unknown Meeting Topic'
            ELSE TRIM(m.meeting_topic)
        END AS meeting_topic,
        
        -- Derive meeting type from duration and other attributes
        CASE 
            WHEN COALESCE(m.duration_minutes, 0) <= 30 THEN 'Instant'
            WHEN COALESCE(m.duration_minutes, 0) <= 60 THEN 'Scheduled'
            WHEN COALESCE(m.duration_minutes, 0) > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS meeting_type,
        
        -- Validate and correct start time
        CASE 
            WHEN m.start_time > DATEADD('year', 1, CURRENT_TIMESTAMP())
            THEN CURRENT_TIMESTAMP()
            ELSE COALESCE(m.start_time, CURRENT_TIMESTAMP())
        END AS start_time,
        
        -- Validate and correct end time
        CASE 
            WHEN m.end_time IS NULL 
            THEN DATEADD('minute', COALESCE(m.duration_minutes, 60), COALESCE(m.start_time, CURRENT_TIMESTAMP()))
            WHEN m.end_time < COALESCE(m.start_time, CURRENT_TIMESTAMP()) 
            THEN DATEADD('minute', COALESCE(m.duration_minutes, 60), COALESCE(m.start_time, CURRENT_TIMESTAMP()))
            WHEN m.end_time > DATEADD('year', 1, CURRENT_TIMESTAMP())
            THEN CURRENT_TIMESTAMP()
            ELSE m.end_time
        END AS end_time,
        
        -- Recalculate and validate duration
        CASE 
            WHEN m.duration_minutes IS NULL OR m.duration_minutes < 0
            THEN GREATEST(1, DATEDIFF('minute', COALESCE(m.start_time, CURRENT_TIMESTAMP()), 
                 COALESCE(m.end_time, DATEADD('minute', 60, COALESCE(m.start_time, CURRENT_TIMESTAMP())))))
            WHEN m.duration_minutes > 1440  -- More than 24 hours
            THEN 1440
            ELSE m.duration_minutes
        END AS duration_minutes,
        
        -- Get host name
        COALESCE(h.user_name, 'Unknown Host') AS host_name,
        
        -- Derive meeting status from timestamps
        CASE 
            WHEN m.end_time IS NULL AND COALESCE(m.start_time, CURRENT_TIMESTAMP()) <= CURRENT_TIMESTAMP()
            THEN 'In Progress'
            WHEN m.end_time IS NOT NULL AND m.end_time <= CURRENT_TIMESTAMP()
            THEN 'Completed'
            WHEN COALESCE(m.start_time, CURRENT_TIMESTAMP()) > CURRENT_TIMESTAMP()
            THEN 'Scheduled'
            ELSE 'Cancelled'
        END AS meeting_status,
        
        -- Derive recording status (simplified logic)
        CASE 
            WHEN COALESCE(m.duration_minutes, 0) > 30 THEN 'Yes'
            ELSE 'No'
        END AS recording_status,
        
        -- Get participant count
        COALESCE(p.participant_count, 0) AS participant_count,
        
        COALESCE(m.load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(m.update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(m.source_system, 'ZOOM_PLATFORM') AS source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN m.meeting_id IS NOT NULL 
                 AND m.host_id IS NOT NULL
                 AND m.start_time IS NOT NULL
                 AND COALESCE(m.duration_minutes, 0) > 0
            THEN 1.00
            WHEN m.meeting_id IS NOT NULL AND m.host_id IS NOT NULL
            THEN 0.75
            WHEN m.meeting_id IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(COALESCE(m.load_timestamp, CURRENT_TIMESTAMP())) AS load_date,
        DATE(COALESCE(m.update_timestamp, CURRENT_TIMESTAMP())) AS update_date
    FROM bronze_meetings m
    LEFT JOIN host_info h ON m.host_id = h.user_id
    LEFT JOIN participant_counts p ON m.meeting_id = p.meeting_id
),

-- Remove duplicates keeping the latest record
meetings_deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY update_timestamp DESC) AS rn
    FROM meetings_cleaned
)

SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    meeting_type,
    start_time,
    end_time,
    duration_minutes,
    host_name,
    meeting_status,
    recording_status,
    participant_count,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM meetings_deduped
WHERE rn = 1
  AND duration_minutes > 0  -- Ensure positive duration
  AND data_quality_score >= 0.50  -- Minimum quality threshold
