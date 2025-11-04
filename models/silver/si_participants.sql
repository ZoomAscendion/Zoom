{{ config(
    materialized='table'
) }}

-- Silver Participants Model - Cleaned participant attendance data
-- Transforms Bronze participant data with calculated attendance metrics

WITH bronze_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE participant_id IS NOT NULL
),

-- Data Quality Checks and Cleansing
participants_cleaned AS (
    SELECT 
        p.participant_id,
        p.meeting_id,
        p.user_id,
        
        -- Validate and correct join time
        CASE 
            WHEN p.join_time > DATEADD('year', 1, CURRENT_TIMESTAMP())
            THEN CURRENT_TIMESTAMP()
            ELSE p.join_time
        END AS join_time,
        
        -- Validate and correct leave time
        CASE 
            WHEN p.leave_time IS NULL 
            THEN DATEADD('minute', 30, p.join_time)  -- Default 30 minutes if null
            WHEN p.leave_time < p.join_time 
            THEN DATEADD('minute', 5, p.join_time)   -- Minimum 5 minutes if invalid
            WHEN p.leave_time > DATEADD('year', 1, CURRENT_TIMESTAMP())
            THEN CURRENT_TIMESTAMP()
            ELSE p.leave_time
        END AS leave_time,
        
        -- Calculate attendance duration
        GREATEST(0, DATEDIFF('minute', 
            p.join_time, 
            COALESCE(
                CASE 
                    WHEN p.leave_time < p.join_time THEN DATEADD('minute', 5, p.join_time)
                    ELSE p.leave_time
                END, 
                DATEADD('minute', 30, p.join_time)
            )
        )) AS attendance_duration,
        
        -- Derive participant role (simplified logic)
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM {{ source('bronze', 'bz_meetings') }} m 
                WHERE m.meeting_id = p.meeting_id AND m.host_id = p.user_id
            ) THEN 'Host'
            ELSE 'Participant'
        END AS participant_role,
        
        -- Derive connection quality from attendance patterns
        CASE 
            WHEN DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, DATEADD('minute', 30, p.join_time))) >= 30
            THEN 'Excellent'
            WHEN DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, DATEADD('minute', 30, p.join_time))) >= 15
            THEN 'Good'
            WHEN DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, DATEADD('minute', 30, p.join_time))) >= 5
            THEN 'Fair'
            ELSE 'Poor'
        END AS connection_quality,
        
        p.load_timestamp,
        p.update_timestamp,
        p.source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN p.participant_id IS NOT NULL 
                 AND p.meeting_id IS NOT NULL
                 AND p.user_id IS NOT NULL
                 AND p.join_time IS NOT NULL
                 AND COALESCE(p.leave_time, DATEADD('minute', 30, p.join_time)) >= p.join_time
            THEN 1.00
            WHEN p.participant_id IS NOT NULL AND p.meeting_id IS NOT NULL AND p.user_id IS NOT NULL
            THEN 0.75
            WHEN p.participant_id IS NOT NULL AND p.meeting_id IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(p.load_timestamp) AS load_date,
        DATE(p.update_timestamp) AS update_date
    FROM bronze_participants p
),

-- Remove duplicates keeping the latest record
participants_deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY update_timestamp DESC) AS rn
    FROM participants_cleaned
)

SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    attendance_duration,
    participant_role,
    connection_quality,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM participants_deduped
WHERE rn = 1
  AND meeting_id IS NOT NULL  -- Ensure no null meeting_id
  AND user_id IS NOT NULL     -- Ensure no null user_id
  AND attendance_duration >= 0  -- Ensure non-negative duration
  AND data_quality_score >= 0.50  -- Minimum quality threshold
