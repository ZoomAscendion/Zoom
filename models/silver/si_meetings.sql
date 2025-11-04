{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_MEETINGS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_MEETINGS_ETL', CURRENT_TIMESTAMP(), 'Started', 'BZ_MEETINGS,BZ_USERS,BZ_PARTICIPANTS', 'SI_MEETINGS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_MEETINGS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_MEETINGS_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Meetings Table - Cleaned and enriched meeting data
-- Includes calculated metrics and data quality validations

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'bz_meetings') }}
),

bronze_users AS (
    SELECT user_id, user_name
    FROM {{ source('bronze', 'bz_users') }}
),

participant_counts AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ source('bronze', 'bz_participants') }}
    GROUP BY meeting_id
),

-- Data Quality Validation and Cleansing
meetings_cleaned AS (
    SELECT
        bm.meeting_id,
        bm.host_id,
        
        -- Clean and standardize meeting topic
        CASE 
            WHEN bm.meeting_topic IS NULL OR TRIM(bm.meeting_topic) = '' THEN 'Untitled Meeting'
            ELSE TRIM(bm.meeting_topic)
        END AS meeting_topic,
        
        -- Derive meeting type from duration
        CASE 
            WHEN bm.duration_minutes <= 30 THEN 'Instant'
            WHEN bm.duration_minutes <= 60 THEN 'Scheduled'
            WHEN bm.duration_minutes > 60 THEN 'Extended'
            ELSE 'Personal'
        END AS meeting_type,
        
        -- Validate and correct timestamps
        CASE 
            WHEN bm.start_time IS NULL THEN CURRENT_TIMESTAMP()
            ELSE bm.start_time
        END AS start_time,
        
        CASE 
            WHEN bm.end_time IS NULL OR bm.end_time < bm.start_time 
                THEN DATEADD('minute', COALESCE(bm.duration_minutes, 60), bm.start_time)
            ELSE bm.end_time
        END AS end_time,
        
        -- Validate and recalculate duration
        CASE 
            WHEN bm.duration_minutes IS NULL OR bm.duration_minutes < 0 
                THEN DATEDIFF('minute', bm.start_time, 
                    CASE WHEN bm.end_time < bm.start_time 
                         THEN DATEADD('minute', 60, bm.start_time)
                         ELSE COALESCE(bm.end_time, DATEADD('minute', 60, bm.start_time))
                    END)
            WHEN bm.duration_minutes > 1440 THEN 1440  -- Cap at 24 hours
            ELSE bm.duration_minutes
        END AS duration_minutes,
        
        -- Get host name from users table
        COALESCE(bu.user_name, 'Unknown Host') AS host_name,
        
        -- Derive meeting status
        CASE 
            WHEN bm.end_time IS NULL THEN 'Scheduled'
            WHEN bm.end_time < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN bm.start_time <= CURRENT_TIMESTAMP() AND bm.end_time > CURRENT_TIMESTAMP() THEN 'In Progress'
            ELSE 'Scheduled'
        END AS meeting_status,
        
        -- Derive recording status (simplified logic)
        CASE 
            WHEN bm.duration_minutes > 30 THEN 'Yes'
            ELSE 'No'
        END AS recording_status,
        
        -- Get participant count
        COALESCE(pc.participant_count, 0) AS participant_count,
        
        -- Metadata columns
        bm.load_timestamp,
        bm.update_timestamp,
        bm.source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN bm.meeting_id IS NOT NULL 
                AND bm.host_id IS NOT NULL
                AND bm.start_time IS NOT NULL
                AND bm.end_time IS NOT NULL
                AND bm.end_time >= bm.start_time
                AND bm.duration_minutes > 0
                THEN 1.00
            WHEN bm.meeting_id IS NOT NULL AND bm.host_id IS NOT NULL
                THEN 0.75
            WHEN bm.meeting_id IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(bm.load_timestamp) AS load_date,
        DATE(bm.update_timestamp) AS update_date
        
    FROM bronze_meetings bm
    LEFT JOIN bronze_users bu ON bm.host_id = bu.user_id
    LEFT JOIN participant_counts pc ON bm.meeting_id = pc.meeting_id
    WHERE bm.meeting_id IS NOT NULL  -- Block records without meeting_id
        AND bm.host_id IS NOT NULL   -- Block records without host_id
),

-- Remove duplicates - keep latest record
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
    AND data_quality_score >= 0.50  -- Only high quality records
    AND duration_minutes > 0        -- Ensure positive duration
