{{ config(
    materialized='table'
) }}

-- Gold Meeting Facts Table
WITH meeting_base AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        m.meeting_topic,
        m.start_time,
        m.end_time,
        m.duration_minutes,
        m.meeting_type,
        m.time_zone,
        m.meeting_size_category,
        m.business_hours_flag,
        m.load_date as m_load_date,
        m.update_date as m_update_date,
        m.source_system as m_source_system
    FROM {{ source('silver', 'si_meetings') }} m
),

host_info AS (
    SELECT 
        u.user_id,
        u.user_name
    FROM {{ source('silver', 'si_users') }} u
),

participant_agg AS (
    SELECT 
        p.meeting_id,
        COUNT(DISTINCT p.participant_id) as participant_count,
        SUM(COALESCE(p.attendance_duration_minutes, 0)) as total_attendance_minutes
    FROM {{ source('silver', 'si_participants') }} p
    GROUP BY p.meeting_id
),

feature_usage_agg AS (
    SELECT 
        f.meeting_id,
        SUM(COALESCE(f.usage_count, 0)) as feature_usage_count
    FROM {{ source('silver', 'si_feature_usage') }} f
    GROUP BY f.meeting_id
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY mb.meeting_id) as meeting_fact_id,
    DATE(mb.start_time) as meeting_date,
    COALESCE(h.user_name, 'Unknown Host') as host_name,
    COALESCE(mb.meeting_topic, 'Untitled Meeting') as meeting_topic,
    COALESCE(mb.duration_minutes, 0) as duration_minutes,
    COALESCE(mb.meeting_type, 'Unknown') as meeting_type,
    COALESCE(pa.participant_count, 0) as participant_count,
    COALESCE(pa.total_attendance_minutes, 0) as total_attendance_minutes,
    CASE 
        WHEN mb.duration_minutes > 0 AND pa.participant_count > 0 AND pa.total_attendance_minutes > 0 
        THEN ROUND((pa.total_attendance_minutes::FLOAT / (mb.duration_minutes * pa.participant_count)) * 100, 2)
        ELSE 0 
    END as average_attendance_percentage,
    COALESCE(fua.feature_usage_count, 0) as feature_usage_count,
    COALESCE(mb.business_hours_flag, FALSE) as business_hours_flag,
    COALESCE(mb.meeting_size_category, 'Small') as meeting_size_category,
    -- Additional columns from Silver layer
    mb.meeting_id,
    mb.host_id,
    mb.start_time,
    mb.end_time,
    COALESCE(mb.time_zone, 'UTC') as time_zone,
    -- Metadata columns
    COALESCE(mb.m_load_date, CURRENT_DATE()) as load_date,
    COALESCE(mb.m_update_date, CURRENT_DATE()) as update_date,
    COALESCE(mb.m_source_system, 'ZOOM_PLATFORM') as source_system
FROM meeting_base mb
LEFT JOIN host_info h ON mb.host_id = h.user_id
LEFT JOIN participant_agg pa ON mb.meeting_id = pa.meeting_id
LEFT JOIN feature_usage_agg fua ON mb.meeting_id = fua.meeting_id
