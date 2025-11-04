{{ config(
    materialized='table'
) }}

-- Silver Participants Table - Cleaned participant attendance data
-- Includes calculated attendance metrics and data quality validations

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
),

-- Data Quality Validation and Cleansing
participants_cleaned AS (
    SELECT
        bp.participant_id,
        bp.meeting_id,
        bp.user_id,
        
        -- Validate and correct join time
        CASE 
            WHEN bp.join_time IS NULL THEN CURRENT_TIMESTAMP()
            WHEN bp.join_time > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR 
                THEN CURRENT_TIMESTAMP()
            ELSE bp.join_time
        END AS join_time,
        
        -- Validate and correct leave time
        CASE 
            WHEN bp.leave_time IS NULL 
                THEN DATEADD('minute', 30, bp.join_time)  -- Default 30 min attendance
            WHEN bp.leave_time < bp.join_time 
                THEN DATEADD('minute', 1, bp.join_time)   -- Minimum 1 minute attendance
            WHEN bp.leave_time > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR 
                THEN CURRENT_TIMESTAMP()
            ELSE bp.leave_time
        END AS leave_time,
        
        -- Calculate attendance duration in minutes
        CASE 
            WHEN bp.leave_time IS NULL OR bp.leave_time < bp.join_time
                THEN 30  -- Default duration
            ELSE DATEDIFF('minute', bp.join_time, bp.leave_time)
        END AS attendance_duration,
        
        -- Derive participant role (simplified logic)
        CASE 
            WHEN bp.user_id = (SELECT host_id FROM {{ source('bronze', 'bz_meetings') }} bm WHERE bm.meeting_id = bp.meeting_id LIMIT 1)
                THEN 'Host'
            ELSE 'Participant'
        END AS participant_role,
        
        -- Derive connection quality from attendance duration
        CASE 
            WHEN DATEDIFF('minute', bp.join_time, COALESCE(bp.leave_time, DATEADD('minute', 30, bp.join_time))) >= 60
                THEN 'Excellent'
            WHEN DATEDIFF('minute', bp.join_time, COALESCE(bp.leave_time, DATEADD('minute', 30, bp.join_time))) >= 30
                THEN 'Good'
            WHEN DATEDIFF('minute', bp.join_time, COALESCE(bp.leave_time, DATEADD('minute', 30, bp.join_time))) >= 10
                THEN 'Fair'
            ELSE 'Poor'
        END AS connection_quality,
        
        -- Metadata columns
        bp.load_timestamp,
        bp.update_timestamp,
        bp.source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN bp.participant_id IS NOT NULL 
                AND bp.meeting_id IS NOT NULL
                AND bp.user_id IS NOT NULL
                AND bp.join_time IS NOT NULL
                AND bp.leave_time IS NOT NULL
                AND bp.leave_time >= bp.join_time
                THEN 1.00
            WHEN bp.participant_id IS NOT NULL AND bp.meeting_id IS NOT NULL AND bp.user_id IS NOT NULL
                THEN 0.75
            WHEN bp.participant_id IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(bp.load_timestamp) AS load_date,
        DATE(bp.update_timestamp) AS update_date
        
    FROM bronze_participants bp
    WHERE bp.participant_id IS NOT NULL  -- Block records without participant_id
        AND bp.meeting_id IS NOT NULL    -- Block records without meeting_id
        AND bp.user_id IS NOT NULL       -- Block records without user_id
),

-- Remove duplicates - keep latest record
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
    AND data_quality_score >= 0.50  -- Only high quality records
    AND attendance_duration > 0     -- Ensure positive attendance duration
