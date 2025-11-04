{{ config(
    materialized='table'
) }}

-- Silver Layer Participants Transformation
-- Source: Bronze.BZ_PARTICIPANTS
-- Target: Silver.SI_PARTICIPANTS
-- Description: Transforms and cleanses participant data with attendance calculations

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
      AND meeting_id IS NOT NULL
      AND user_id IS NOT NULL
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        
        -- Validate and correct timestamps
        CASE 
            WHEN join_time IS NULL THEN CURRENT_TIMESTAMP()
            ELSE join_time
        END AS join_time_clean,
        
        CASE 
            WHEN leave_time IS NULL OR leave_time < join_time 
                THEN DATEADD('minute', 60, COALESCE(join_time, CURRENT_TIMESTAMP()))
            ELSE leave_time
        END AS leave_time_clean,
        
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_participants
),

-- Calculate derived fields
derived_fields AS (
    SELECT 
        *,
        -- Calculate attendance duration in minutes
        DATEDIFF('minute', join_time_clean, leave_time_clean) AS attendance_duration,
        
        -- Derive participant role (simplified logic)
        CASE 
            WHEN DATEDIFF('minute', join_time_clean, leave_time_clean) >= 90 THEN 'Host'
            WHEN DATEDIFF('minute', join_time_clean, leave_time_clean) >= 30 THEN 'Participant'
            ELSE 'Observer'
        END AS participant_role,
        
        -- Derive connection quality based on attendance patterns
        CASE 
            WHEN DATEDIFF('minute', join_time_clean, leave_time_clean) >= 60 THEN 'Excellent'
            WHEN DATEDIFF('minute', join_time_clean, leave_time_clean) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', join_time_clean, leave_time_clean) >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS connection_quality
    FROM data_quality_checks
),

-- Calculate data quality score
quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        (
            CASE WHEN join_time_clean IS NOT NULL THEN 0.30 ELSE 0 END +
            CASE WHEN leave_time_clean IS NOT NULL THEN 0.30 ELSE 0 END +
            CASE WHEN attendance_duration > 0 THEN 0.25 ELSE 0 END +
            CASE WHEN participant_role != 'Observer' THEN 0.15 ELSE 0 END
        ) AS data_quality_score
    FROM derived_fields
),

-- Remove duplicates keeping the most recent record
deduped_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time_clean AS join_time,
        leave_time_clean AS leave_time,
        attendance_duration,
        participant_role,
        connection_quality,
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY update_timestamp DESC) AS rn
    FROM quality_scored
    WHERE data_quality_score >= {{ var('dq_score_threshold') }}
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
    DATE(load_timestamp) AS load_date,
    DATE(update_timestamp) AS update_date
FROM deduped_participants
WHERE rn = 1
  AND join_time IS NOT NULL
  AND attendance_duration >= 0
