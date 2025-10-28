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
),

meeting_enriched AS (
    SELECT 
        mb.*,
        h.user_name as host_name,
        COALESCE(pa.participant_count, 0) as participant_count,
        COALESCE(pa.total_attendance_minutes, 0) as total_attendance_minutes,
        COALESCE(fua.feature_usage_count, 0) as feature_usage_count
    FROM meeting_base mb
    LEFT JOIN host_info h ON mb.host_id = h.user_id
    LEFT JOIN participant_agg pa ON mb.meeting_id = pa.meeting_id
    LEFT JOIN feature_usage_agg fua ON mb.meeting_id = fua.meeting_id
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY meeting_id) as meeting_fact_id,
    DATE(start_time) as meeting_date,
    COALESCE(host_name, 'Unknown Host') as host_name,
    COALESCE(meeting_topic, 'Untitled Meeting') as meeting_topic,
    COALESCE(duration_minutes, 0) as duration_minutes,
    COALESCE(meeting_type, 'Unknown') as meeting_type,
    participant_count,
    total_attendance_minutes,
    CASE 
        WHEN duration_minutes > 0 AND participant_count > 0 AND total_attendance_minutes > 0 
        THEN ROUND((total_attendance_minutes::FLOAT / (duration_minutes * participant_count)) * 100, 2)
        ELSE 0 
    END as average_attendance_percentage,
    feature_usage_count,
    COALESCE(business_hours_flag, FALSE) as business_hours_flag,
    COALESCE(meeting_size_category, 'Small') as meeting_size_category,
    -- Additional columns from Silver layer
    meeting_id,
    host_id,
    start_time,
    end_time,
    COALESCE(time_zone, 'UTC') as time_zone,
    -- Metadata columns
    COALESCE(m_load_date, CURRENT_DATE()) as load_date,
    COALESCE(m_update_date, CURRENT_DATE()) as update_date,
    COALESCE(m_source_system, 'ZOOM_PLATFORM') as source_system
FROM meeting_enriched
