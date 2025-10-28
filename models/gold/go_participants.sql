{{ config(
    materialized='table'
) }}

-- Gold Participants Table (Enhanced from Silver)
SELECT 
    ROW_NUMBER() OVER (ORDER BY participant_id) as participant_gold_id,
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    COALESCE(attendance_duration_minutes, 0) as attendance_duration_minutes,
    COALESCE(attendance_percentage, 0.00) as attendance_percentage,
    COALESCE(late_join_flag, FALSE) as late_join_flag,
    COALESCE(early_leave_flag, FALSE) as early_leave_flag,
    COALESCE(engagement_score, 0.00) as engagement_score,
    -- Metadata columns
    COALESCE(load_date, CURRENT_DATE()) as load_date,
    COALESCE(update_date, CURRENT_DATE()) as update_date,
    COALESCE(source_system, 'ZOOM_PLATFORM') as source_system
FROM {{ source('silver', 'si_participants') }}
