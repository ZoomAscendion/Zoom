{{ config(
    materialized='table',
    tags=['dimension'],
    cluster_by=['MEETING_TYPE', 'MEETING_CATEGORY']
) }}

-- Meeting type dimension with comprehensive meeting characteristics
-- Derives meeting types from Silver meeting data patterns

WITH meeting_patterns AS (
    SELECT DISTINCT
        m.meeting_topic,
        m.duration_minutes,
        COUNT(*) OVER (PARTITION BY m.meeting_topic) as topic_frequency
    FROM {{ source('silver', 'si_meetings') }} m
    WHERE m.validation_status = 'PASSED'
      AND m.data_quality_score >= 80
      AND m.meeting_topic IS NOT NULL
      AND TRIM(m.meeting_topic) != ''
),

meeting_types_derived AS (
    SELECT 
        -- Derive meeting type from topic patterns
        CASE 
            WHEN UPPER(mp.meeting_topic) LIKE '%STANDUP%' OR UPPER(mp.meeting_topic) LIKE '%DAILY%' THEN 'Daily Standup'
            WHEN UPPER(mp.meeting_topic) LIKE '%TRAINING%' OR UPPER(mp.meeting_topic) LIKE '%WORKSHOP%' THEN 'Training Session'
            WHEN UPPER(mp.meeting_topic) LIKE '%INTERVIEW%' OR UPPER(mp.meeting_topic) LIKE '%HIRING%' THEN 'Interview'
            WHEN UPPER(mp.meeting_topic) LIKE '%DEMO%' OR UPPER(mp.meeting_topic) LIKE '%PRESENTATION%' THEN 'Presentation'
            WHEN UPPER(mp.meeting_topic) LIKE '%REVIEW%' OR UPPER(mp.meeting_topic) LIKE '%RETROSPECTIVE%' THEN 'Review Meeting'
            WHEN UPPER(mp.meeting_topic) LIKE '%PLANNING%' OR UPPER(mp.meeting_topic) LIKE '%STRATEGY%' THEN 'Planning Session'
            WHEN UPPER(mp.meeting_topic) LIKE '%CLIENT%' OR UPPER(mp.meeting_topic) LIKE '%CUSTOMER%' THEN 'Client Meeting'
            WHEN UPPER(mp.meeting_topic) LIKE '%TEAM%' OR UPPER(mp.meeting_topic) LIKE '%SYNC%' THEN 'Team Meeting'
            WHEN UPPER(mp.meeting_topic) LIKE '%WEBINAR%' OR UPPER(mp.meeting_topic) LIKE '%SEMINAR%' THEN 'Webinar'
            WHEN UPPER(mp.meeting_topic) LIKE '%ONE%ON%ONE%' OR UPPER(mp.meeting_topic) LIKE '%1:1%' THEN 'One-on-One'
            ELSE 'General Meeting'
        END AS meeting_type,
        
        mp.duration_minutes,
        mp.topic_frequency
        
    FROM meeting_patterns mp
),

meeting_type_aggregated AS (
    SELECT DISTINCT
        meeting_type,
        AVG(duration_minutes) as avg_duration,
        SUM(topic_frequency) as total_frequency
    FROM meeting_types_derived
    GROUP BY meeting_type
),

meeting_type_enriched AS (
    SELECT 
        mta.meeting_type,
        
        -- Meeting category classification
        CASE 
            WHEN mta.meeting_type IN ('Daily Standup', 'Team Meeting', 'One-on-One') THEN 'Internal'
            WHEN mta.meeting_type IN ('Client Meeting', 'Presentation', 'Demo') THEN 'External'
            WHEN mta.meeting_type IN ('Training Session', 'Workshop', 'Webinar') THEN 'Educational'
            WHEN mta.meeting_type IN ('Interview', 'Hiring') THEN 'Recruitment'
            WHEN mta.meeting_type IN ('Review Meeting', 'Planning Session') THEN 'Strategic'
            ELSE 'General'
        END AS meeting_category,
        
        -- Duration category based on average duration
        CASE 
            WHEN mta.avg_duration <= 15 THEN 'Quick (≤15 min)'
            WHEN mta.avg_duration <= 30 THEN 'Short (16-30 min)'
            WHEN mta.avg_duration <= 60 THEN 'Standard (31-60 min)'
            WHEN mta.avg_duration <= 120 THEN 'Long (61-120 min)'
            ELSE 'Extended (>120 min)'
        END AS duration_category,
        
        -- Participant size category (estimated based on meeting type)
        CASE 
            WHEN mta.meeting_type = 'One-on-One' THEN 'Small (2-5)'
            WHEN mta.meeting_type IN ('Daily Standup', 'Team Meeting') THEN 'Medium (6-15)'
            WHEN mta.meeting_type IN ('Training Session', 'Webinar') THEN 'Large (16-50)'
            WHEN mta.meeting_type = 'Presentation' THEN 'Very Large (50+)'
            ELSE 'Medium (6-15)'
        END AS participant_size_category,
        
        -- Time of day category (estimated based on meeting type)
        CASE 
            WHEN mta.meeting_type = 'Daily Standup' THEN 'Morning'
            WHEN mta.meeting_type IN ('Training Session', 'Workshop') THEN 'Afternoon'
            WHEN mta.meeting_type = 'Webinar' THEN 'Evening'
            ELSE 'Business Hours'
        END AS time_of_day_category,
        
        -- Recurring type flag
        CASE 
            WHEN mta.meeting_type IN ('Daily Standup', 'Team Meeting', 'One-on-One') THEN TRUE
            ELSE FALSE
        END AS is_recurring_type,
        
        -- Registration requirement
        CASE 
            WHEN mta.meeting_type IN ('Webinar', 'Training Session', 'Workshop') THEN TRUE
            ELSE FALSE
        END AS requires_registration,
        
        -- Recording support
        CASE 
            WHEN mta.meeting_type IN ('Training Session', 'Webinar', 'Presentation', 'Workshop') THEN TRUE
            ELSE FALSE
        END AS supports_recording,
        
        -- Max participants allowed
        CASE 
            WHEN mta.meeting_type = 'One-on-One' THEN 2
            WHEN mta.meeting_type IN ('Daily Standup', 'Team Meeting') THEN 15
            WHEN mta.meeting_type IN ('Training Session', 'Workshop') THEN 50
            WHEN mta.meeting_type = 'Webinar' THEN 1000
            WHEN mta.meeting_type = 'Presentation' THEN 500
            ELSE 25
        END AS max_participants_allowed,
        
        -- Security level
        CASE 
            WHEN mta.meeting_type IN ('Client Meeting', 'Interview') THEN 'High'
            WHEN mta.meeting_type IN ('Team Meeting', 'Planning Session') THEN 'Medium'
            ELSE 'Standard'
        END AS security_level,
        
        -- Meeting format
        CASE 
            WHEN mta.meeting_type IN ('Webinar', 'Training Session') THEN 'Broadcast'
            WHEN mta.meeting_type = 'Presentation' THEN 'Presentation'
            WHEN mta.meeting_type = 'Workshop' THEN 'Interactive'
            ELSE 'Discussion'
        END AS meeting_format
        
    FROM meeting_type_aggregated mta
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY meeting_type) AS meeting_type_id,
    meeting_type,
    meeting_category,
    duration_category,
    participant_size_category,
    time_of_day_category,
    is_recurring_type,
    requires_registration,
    supports_recording,
    max_participants_allowed,
    security_level,
    meeting_format,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_GOLD_PIPELINE' AS source_system
    
FROM meeting_type_enriched
ORDER BY meeting_type_id
