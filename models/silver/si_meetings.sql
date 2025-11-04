{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.si_pipeline_audit (execution_id, pipeline_name, start_time, status, executed_by) VALUES (REPLACE(UUID_STRING(), '-', ''), 'si_meetings_transform', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_USER())",
    post_hook="UPDATE {{ this.database }}.{{ this.schema }}.si_pipeline_audit SET end_time = CURRENT_TIMESTAMP(), status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE pipeline_name = 'si_meetings_transform' AND status = 'STARTED'"
) }}

-- Silver Layer Meetings Transformation
-- Source: Bronze.BZ_MEETINGS, Bronze.BZ_USERS, Bronze.BZ_PARTICIPANTS
-- Target: Silver.SI_MEETINGS
-- Description: Transforms and enriches meeting data with host information and participant counts

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
    FROM {{ ref('bronze_meetings') }}
    WHERE meeting_id IS NOT NULL
      AND host_id IS NOT NULL
),

host_info AS (
    SELECT 
        user_id,
        user_name
    FROM {{ ref('si_users') }}
),

participant_counts AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ ref('bronze_participants') }}
    WHERE meeting_id IS NOT NULL
    GROUP BY meeting_id
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        bm.meeting_id,
        bm.host_id,
        
        -- Clean and standardize meeting topic
        CASE 
            WHEN bm.meeting_topic IS NULL OR TRIM(bm.meeting_topic) = '' THEN 'Untitled Meeting'
            ELSE TRIM(bm.meeting_topic)
        END AS meeting_topic_clean,
        
        -- Derive meeting type from duration and other attributes
        CASE 
            WHEN bm.duration_minutes <= 30 THEN 'Instant'
            WHEN bm.duration_minutes <= 120 THEN 'Scheduled'
            WHEN bm.duration_minutes > 120 THEN 'Webinar'
            ELSE 'Personal'
        END AS meeting_type,
        
        -- Validate and correct timestamps
        CASE 
            WHEN bm.start_time IS NULL THEN CURRENT_TIMESTAMP()
            ELSE bm.start_time
        END AS start_time_clean,
        
        CASE 
            WHEN bm.end_time IS NULL OR bm.end_time < bm.start_time 
                THEN DATEADD('minute', COALESCE(bm.duration_minutes, 60), bm.start_time)
            ELSE bm.end_time
        END AS end_time_clean,
        
        -- Recalculate and validate duration
        CASE 
            WHEN bm.duration_minutes IS NULL OR bm.duration_minutes <= 0
                THEN GREATEST(1, DATEDIFF('minute', bm.start_time, 
                    CASE WHEN bm.end_time < bm.start_time THEN DATEADD('hour', 1, bm.start_time) ELSE bm.end_time END))
            WHEN bm.duration_minutes > 1440 THEN 1440  -- Cap at 24 hours
            ELSE bm.duration_minutes
        END AS duration_minutes_clean,
        
        -- Get host name from users table
        COALESCE(hi.user_name, 'Unknown Host') AS host_name,
        
        -- Derive meeting status from timestamps
        CASE 
            WHEN bm.end_time IS NULL AND bm.start_time > CURRENT_TIMESTAMP() THEN 'Scheduled'
            WHEN bm.end_time IS NULL AND bm.start_time <= CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN bm.end_time IS NOT NULL AND bm.end_time <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Cancelled'
        END AS meeting_status,
        
        -- Derive recording status (simplified logic)
        CASE 
            WHEN bm.duration_minutes > 30 THEN 'Yes'
            ELSE 'No'
        END AS recording_status,
        
        -- Get participant count
        COALESCE(pc.participant_count, 0) AS participant_count,
        
        bm.load_timestamp,
        bm.update_timestamp,
        bm.source_system
    FROM bronze_meetings bm
    LEFT JOIN host_info hi ON bm.host_id = hi.user_id
    LEFT JOIN participant_counts pc ON bm.meeting_id = pc.meeting_id
),

-- Calculate data quality score
quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        (
            CASE WHEN meeting_topic_clean != 'Untitled Meeting' THEN 0.20 ELSE 0 END +
            CASE WHEN host_name != 'Unknown Host' THEN 0.25 ELSE 0 END +
            CASE WHEN start_time_clean IS NOT NULL THEN 0.20 ELSE 0 END +
            CASE WHEN end_time_clean IS NOT NULL THEN 0.20 ELSE 0 END +
            CASE WHEN duration_minutes_clean > 0 THEN 0.15 ELSE 0 END
        ) AS data_quality_score
    FROM data_quality_checks
),

-- Remove duplicates keeping the most recent record
deduped_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic_clean AS meeting_topic,
        meeting_type,
        start_time_clean AS start_time,
        end_time_clean AS end_time,
        duration_minutes_clean AS duration_minutes,
        host_name,
        meeting_status,
        recording_status,
        participant_count,
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY update_timestamp DESC) AS rn
    FROM quality_scored
    WHERE data_quality_score >= {{ var('dq_score_threshold') }}
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
    DATE(load_timestamp) AS load_date,
    DATE(update_timestamp) AS update_date
FROM deduped_meetings
WHERE rn = 1
  AND start_time IS NOT NULL
  AND end_time IS NOT NULL
  AND duration_minutes > 0
