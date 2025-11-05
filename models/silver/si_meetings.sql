{{ config(
    materialized='table'
) }}

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

data_quality_checks AS (
    SELECT 
        bm.*,
        -- Time validation
        CASE 
            WHEN start_time IS NOT NULL AND end_time IS NOT NULL AND end_time >= start_time THEN 1
            ELSE 0
        END AS time_quality,
        
        -- Duration validation
        CASE 
            WHEN duration_minutes >= 1 AND duration_minutes <= 1440 THEN 1
            ELSE 0
        END AS duration_quality,
        
        -- Host validation
        CASE 
            WHEN host_id IS NOT NULL THEN 1
            ELSE 0
        END AS host_quality,
        
        -- Completeness check
        CASE 
            WHEN meeting_id IS NOT NULL AND start_time IS NOT NULL THEN 1
            ELSE 0
        END AS completeness_quality
    FROM bronze_meetings bm
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY meeting_id 
            ORDER BY load_timestamp DESC, update_timestamp DESC
        ) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        dm.meeting_id,
        dm.host_id,
        TRIM(dm.meeting_topic) AS meeting_topic,
        CASE 
            WHEN dm.duration_minutes <= 30 THEN 'Instant'
            WHEN dm.duration_minutes <= 60 THEN 'Scheduled'
            WHEN dm.duration_minutes > 120 THEN 'Webinar'
            ELSE 'Personal'
        END AS meeting_type,
        dm.start_time,
        CASE 
            WHEN dm.end_time < dm.start_time THEN DATEADD('minute', dm.duration_minutes, dm.start_time)
            ELSE dm.end_time
        END AS end_time,
        CASE 
            WHEN dm.duration_minutes < 0 THEN DATEDIFF('minute', dm.start_time, dm.end_time)
            WHEN dm.duration_minutes > 1440 THEN 1440
            ELSE dm.duration_minutes
        END AS duration_minutes,
        COALESCE(bu.user_name, 'Unknown Host') AS host_name,
        CASE 
            WHEN dm.end_time IS NULL OR dm.end_time > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN dm.end_time <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Scheduled'
        END AS meeting_status,
        CASE 
            WHEN dm.meeting_topic ILIKE '%record%' THEN 'Yes'
            ELSE 'No'
        END AS recording_status,
        COALESCE(pc.participant_count, 0) AS participant_count,
        dm.load_timestamp,
        dm.update_timestamp,
        dm.source_system,
        -- Calculate data quality score
        ROUND(
            (dm.time_quality + dm.duration_quality + dm.host_quality + dm.completeness_quality) / 4.0, 2
        ) AS data_quality_score,
        DATE(dm.load_timestamp) AS load_date,
        DATE(dm.update_timestamp) AS update_date
    FROM deduplication dm
    LEFT JOIN bronze_users bu ON dm.host_id = bu.user_id
    LEFT JOIN participant_counts pc ON dm.meeting_id = pc.meeting_id
    WHERE dm.rn = 1
      AND dm.meeting_id IS NOT NULL
      AND dm.start_time IS NOT NULL
      AND dm.host_id IS NOT NULL
      AND (dm.end_time IS NULL OR dm.end_time >= dm.start_time)
)

SELECT * FROM final_transformation
