{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (execution_id, pipeline_name, start_time, status, executed_by, source_tables_processed, target_tables_updated, load_date, update_date, source_system) SELECT CONCAT('MEET_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')), 'SI_MEETINGS_ETL', CURRENT_TIMESTAMP(), 'Started', 'DBT_PIPELINE', 'BZ_MEETINGS', 'SI_MEETINGS', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (execution_id, pipeline_name, end_time, status, executed_by, records_processed, load_date, update_date, source_system) SELECT CONCAT('MEET_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')), 'SI_MEETINGS_ETL', CURRENT_TIMESTAMP(), 'Completed', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Meetings Table
-- Transforms Bronze meetings data with data quality validations and enrichment

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
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE meeting_id IS NOT NULL
      AND host_id IS NOT NULL
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
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE meeting_id IS NOT NULL
    GROUP BY meeting_id
),

-- Data Quality Validations
validated_meetings AS (
    SELECT 
        bm.meeting_id,
        bm.host_id,
        
        -- Standardize meeting topic
        CASE 
            WHEN bm.meeting_topic IS NULL OR TRIM(bm.meeting_topic) = '' THEN 'Untitled Meeting'
            ELSE TRIM(bm.meeting_topic)
        END AS meeting_topic,
        
        -- Derive meeting type from duration
        CASE 
            WHEN bm.duration_minutes <= 30 THEN 'Instant'
            WHEN bm.duration_minutes <= 60 THEN 'Scheduled'
            WHEN bm.duration_minutes > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS meeting_type,
        
        -- Validate timestamps
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
                    CASE WHEN bm.end_time < bm.start_time THEN DATEADD('minute', 60, bm.start_time) ELSE bm.end_time END)
            WHEN bm.duration_minutes > 1440 THEN 1440  -- Cap at 24 hours
            ELSE bm.duration_minutes
        END AS duration_minutes,
        
        -- Get host name
        COALESCE(hi.user_name, 'Unknown Host') AS host_name,
        
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
        
        bm.load_timestamp,
        bm.update_timestamp,
        bm.source_system,
        
        -- Calculate data quality score
        (
            CASE WHEN bm.meeting_id IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN bm.host_id IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN bm.start_time IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN bm.end_time IS NOT NULL AND bm.end_time >= bm.start_time THEN 0.2 ELSE 0 END +
            CASE WHEN bm.duration_minutes IS NOT NULL AND bm.duration_minutes > 0 THEN 0.2 ELSE 0 END
        ) AS data_quality_score
        
    FROM bronze_meetings bm
    LEFT JOIN host_info hi ON bm.host_id = hi.user_id
    LEFT JOIN participant_counts pc ON bm.meeting_id = pc.meeting_id
),

-- Remove duplicates - keep latest record
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY update_timestamp DESC) AS rn
    FROM validated_meetings
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
  AND start_time IS NOT NULL  -- Ensure no null start times in Silver layer
  AND end_time >= start_time  -- Ensure logical time sequence
