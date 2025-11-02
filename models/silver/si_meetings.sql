{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_MEETINGS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_MEETINGS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_MEETINGS', 'SI_MEETINGS', 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, records_inserted, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_MEETINGS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_MEETINGS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Meetings Model
-- Transforms bronze meeting data with enrichment from users table

WITH bronze_meetings AS (
    SELECT * FROM {{ source('bronze', 'bz_meetings') }}
),

silver_users AS (
    SELECT * FROM {{ ref('si_users') }}
),

-- Data Quality Validation
data_quality_checks AS (
    SELECT 
        *,
        -- Temporal validation
        CASE 
            WHEN end_time < start_time THEN 'INVALID_TIME_SEQUENCE'
            WHEN start_time > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN 'FUTURE_START_TIME'
            ELSE 'VALID'
        END AS temporal_quality_flag,
        
        -- Duration validation
        CASE 
            WHEN duration_minutes < 0 THEN 'NEGATIVE_DURATION'
            WHEN duration_minutes > 1440 THEN 'EXCESSIVE_DURATION'
            ELSE 'VALID'
        END AS duration_quality_flag
    FROM bronze_meetings
    WHERE meeting_id IS NOT NULL
      AND host_id IS NOT NULL  -- Block meetings without host
),

-- Data Cleansing and Enrichment
cleansed_meetings AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        
        -- Standardized business columns
        TRIM(m.meeting_topic) AS meeting_topic,
        CASE 
            WHEN m.duration_minutes <= 30 THEN 'Instant'
            WHEN m.duration_minutes <= 120 THEN 'Scheduled'
            ELSE 'Extended'
        END AS meeting_type,
        
        -- Corrected timestamps
        m.start_time,
        CASE 
            WHEN m.temporal_quality_flag = 'INVALID_TIME_SEQUENCE' 
            THEN m.start_time + (m.duration_minutes * INTERVAL '1' MINUTE)
            ELSE m.end_time
        END AS end_time,
        
        -- Corrected duration
        CASE 
            WHEN m.duration_quality_flag = 'NEGATIVE_DURATION' 
            THEN ABS(m.duration_minutes)
            WHEN m.duration_quality_flag = 'EXCESSIVE_DURATION'
            THEN 1440
            ELSE m.duration_minutes
        END AS duration_minutes,
        
        -- Enriched columns from users
        COALESCE(u.user_name, 'Unknown Host') AS host_name,
        
        -- Derived status
        CASE 
            WHEN m.end_time IS NULL OR m.end_time > CURRENT_TIMESTAMP() THEN 'Scheduled'
            WHEN m.end_time <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'In Progress'
        END AS meeting_status,
        
        -- Default values for new columns
        'No' AS recording_status,
        0 AS participant_count,  -- Will be updated via post-hook or separate process
        
        -- Silver layer metadata
        m.load_timestamp,
        m.update_timestamp,
        m.source_system,
        
        -- Data quality score
        ROUND(
            (CASE WHEN m.temporal_quality_flag = 'VALID' THEN 0.4 ELSE 0.0 END +
             CASE WHEN m.duration_quality_flag = 'VALID' THEN 0.3 ELSE 0.0 END +
             CASE WHEN u.user_id IS NOT NULL THEN 0.2 ELSE 0.0 END +
             CASE WHEN m.meeting_topic IS NOT NULL AND TRIM(m.meeting_topic) != '' THEN 0.1 ELSE 0.0 END), 2
        ) AS data_quality_score,
        
        -- Standard metadata
        DATE(m.load_timestamp) AS load_date,
        DATE(m.update_timestamp) AS update_date
        
    FROM data_quality_checks m
    LEFT JOIN silver_users u ON m.host_id = u.user_id
),

-- Deduplication
deduped_meetings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY update_timestamp DESC) AS rn
    FROM cleansed_meetings
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
FROM deduped_meetings
WHERE rn = 1
