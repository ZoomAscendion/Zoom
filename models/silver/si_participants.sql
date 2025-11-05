{{ config(
    materialized='table'
) }}

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
),

bronze_meetings AS (
    SELECT meeting_id, host_id
    FROM {{ source('bronze', 'bz_meetings') }}
),

data_quality_checks AS (
    SELECT 
        bp.*,
        -- Time validation
        CASE 
            WHEN join_time IS NOT NULL AND (leave_time IS NULL OR leave_time >= join_time) THEN 1
            ELSE 0
        END AS time_quality,
        
        -- Reference validation
        CASE 
            WHEN meeting_id IS NOT NULL AND user_id IS NOT NULL THEN 1
            ELSE 0
        END AS reference_quality,
        
        -- Completeness check
        CASE 
            WHEN participant_id IS NOT NULL AND join_time IS NOT NULL THEN 1
            ELSE 0
        END AS completeness_quality
    FROM bronze_participants bp
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY participant_id 
            ORDER BY load_timestamp DESC, update_timestamp DESC
        ) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        dp.participant_id,
        dp.meeting_id,
        dp.user_id,
        dp.join_time,
        CASE 
            WHEN dp.leave_time IS NULL THEN DATEADD('hour', 1, dp.join_time)
            WHEN dp.leave_time < dp.join_time THEN dp.join_time
            ELSE dp.leave_time
        END AS leave_time,
        CASE 
            WHEN dp.leave_time IS NULL THEN 60
            WHEN dp.leave_time < dp.join_time THEN 0
            ELSE DATEDIFF('minute', dp.join_time, dp.leave_time)
        END AS attendance_duration,
        CASE 
            WHEN dp.user_id = bm.host_id THEN 'Host'
            WHEN DATEDIFF('minute', dp.join_time, COALESCE(dp.leave_time, CURRENT_TIMESTAMP())) > 30 THEN 'Participant'
            ELSE 'Observer'
        END AS participant_role,
        CASE 
            WHEN DATEDIFF('minute', dp.join_time, COALESCE(dp.leave_time, CURRENT_TIMESTAMP())) > 45 THEN 'Excellent'
            WHEN DATEDIFF('minute', dp.join_time, COALESCE(dp.leave_time, CURRENT_TIMESTAMP())) > 30 THEN 'Good'
            WHEN DATEDIFF('minute', dp.join_time, COALESCE(dp.leave_time, CURRENT_TIMESTAMP())) > 15 THEN 'Fair'
            ELSE 'Poor'
        END AS connection_quality,
        dp.load_timestamp,
        dp.update_timestamp,
        dp.source_system,
        -- Calculate data quality score
        ROUND(
            (dp.time_quality + dp.reference_quality + dp.completeness_quality) / 3.0, 2
        ) AS data_quality_score,
        DATE(dp.load_timestamp) AS load_date,
        DATE(dp.update_timestamp) AS update_date
    FROM deduplication dp
    LEFT JOIN bronze_meetings bm ON dp.meeting_id = bm.meeting_id
    WHERE dp.rn = 1
      AND dp.participant_id IS NOT NULL
      AND dp.meeting_id IS NOT NULL
      AND dp.user_id IS NOT NULL
      AND dp.join_time IS NOT NULL
      AND (dp.leave_time IS NULL OR dp.leave_time >= dp.join_time)
)

SELECT * FROM final_transformation
