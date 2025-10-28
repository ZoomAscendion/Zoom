{{ config(
    materialized='table'
) }}

-- Gold Webinars Table (Enhanced from Silver)
SELECT 
    ROW_NUMBER() OVER (ORDER BY webinar_id) as webinar_gold_id,
    webinar_id,
    host_id,
    COALESCE(webinar_topic, 'Untitled Webinar') as webinar_topic,
    start_time,
    end_time,
    COALESCE(duration_minutes, 0) as duration_minutes,
    COALESCE(registrants, 0) as registrants,
    COALESCE(actual_attendees, 0) as actual_attendees,
    COALESCE(attendance_rate, 0.00) as attendance_rate,
    COALESCE(webinar_category, 'General') as webinar_category,
    -- Metadata columns
    COALESCE(load_date, CURRENT_DATE()) as load_date,
    COALESCE(update_date, CURRENT_DATE()) as update_date,
    COALESCE(source_system, 'ZOOM_WEBINAR') as source_system
FROM {{ source('silver', 'si_webinars') }}
