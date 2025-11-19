{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['dimension', 'meeting_type']
) }}

-- Meeting type dimension table
-- Categorizes meetings based on various attributes derived from meeting data

WITH source_meetings AS (
    SELECT 
        meeting_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver_layer', 'si_meetings') }}
    WHERE validation_status = 'VALID'
      AND data_quality_score >= {{ var('data_quality_threshold') }}
),

meeting_participants AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ source('silver_layer', 'si_participants') }}
    WHERE validation_status = 'VALID'
    GROUP BY meeting_id
),

meeting_analysis AS (
    SELECT 
        m.meeting_id,
        m.meeting_topic,
        m.duration_minutes,
        COALESCE(p.participant_count, 1) AS participant_count,
        
        -- Extract time components
        HOUR(m.start_time) AS start_hour,
        DAYOFWEEK(m.start_time) AS day_of_week,
        
        -- Meeting type classification based on topic
        CASE 
            WHEN UPPER(m.meeting_topic) LIKE '%STANDUP%' OR UPPER(m.meeting_topic) LIKE '%DAILY%' 
                 OR UPPER(m.meeting_topic) LIKE '%SCRUM%' THEN 'Daily Standup'
            WHEN UPPER(m.meeting_topic) LIKE '%TRAINING%' OR UPPER(m.meeting_topic) LIKE '%WORKSHOP%' 
                 OR UPPER(m.meeting_topic) LIKE '%EDUCATION%' THEN 'Training'
            WHEN UPPER(m.meeting_topic) LIKE '%INTERVIEW%' OR UPPER(m.meeting_topic) LIKE '%HIRING%' THEN 'Interview'
            WHEN UPPER(m.meeting_topic) LIKE '%DEMO%' OR UPPER(m.meeting_topic) LIKE '%PRESENTATION%' 
                 OR UPPER(m.meeting_topic) LIKE '%PITCH%' THEN 'Presentation'
            WHEN UPPER(m.meeting_topic) LIKE '%REVIEW%' OR UPPER(m.meeting_topic) LIKE '%RETROSPECTIVE%' 
                 OR UPPER(m.meeting_topic) LIKE '%FEEDBACK%' THEN 'Review'
            WHEN UPPER(m.meeting_topic) LIKE '%PLANNING%' OR UPPER(m.meeting_topic) LIKE '%STRATEGY%' THEN 'Planning'
            WHEN UPPER(m.meeting_topic) LIKE '%SOCIAL%' OR UPPER(m.meeting_topic) LIKE '%COFFEE%' 
                 OR UPPER(m.meeting_topic) LIKE '%HAPPY%HOUR%' THEN 'Social'
            WHEN UPPER(m.meeting_topic) LIKE '%SUPPORT%' OR UPPER(m.meeting_topic) LIKE '%HELP%' THEN 'Support'
            ELSE 'General Meeting'
        END AS meeting_type,
        
        -- Meeting category
        CASE 
            WHEN UPPER(m.meeting_topic) LIKE '%STANDUP%' OR UPPER(m.meeting_topic) LIKE '%DAILY%' 
                 OR UPPER(m.meeting_topic) LIKE '%SCRUM%' OR UPPER(m.meeting_topic) LIKE '%REVIEW%' THEN 'Operational'
            WHEN UPPER(m.meeting_topic) LIKE '%TRAINING%' OR UPPER(m.meeting_topic) LIKE '%WORKSHOP%' 
                 OR UPPER(m.meeting_topic) LIKE '%EDUCATION%' THEN 'Educational'
            WHEN UPPER(m.meeting_topic) LIKE '%INTERVIEW%' OR UPPER(m.meeting_topic) LIKE '%HIRING%' THEN 'HR'
            WHEN UPPER(m.meeting_topic) LIKE '%DEMO%' OR UPPER(m.meeting_topic) LIKE '%PRESENTATION%' 
                 OR UPPER(m.meeting_topic) LIKE '%PITCH%' THEN 'Business'
            WHEN UPPER(m.meeting_topic) LIKE '%PLANNING%' OR UPPER(m.meeting_topic) LIKE '%STRATEGY%' THEN 'Strategic'
            WHEN UPPER(m.meeting_topic) LIKE '%SOCIAL%' OR UPPER(m.meeting_topic) LIKE '%COFFEE%' THEN 'Social'
            ELSE 'General'
        END AS meeting_category,
        
        -- Duration category
        CASE 
            WHEN m.duration_minutes <= 15 THEN 'Quick (≤15 min)'
            WHEN m.duration_minutes <= 30 THEN 'Short (16-30 min)'
            WHEN m.duration_minutes <= 60 THEN 'Standard (31-60 min)'
            WHEN m.duration_minutes <= 120 THEN 'Long (61-120 min)'
            ELSE 'Extended (>120 min)'
        END AS duration_category,
        
        -- Participant size category
        CASE 
            WHEN COALESCE(p.participant_count, 1) = 1 THEN 'Solo'
            WHEN COALESCE(p.participant_count, 1) <= 5 THEN 'Small (2-5)'
            WHEN COALESCE(p.participant_count, 1) <= 15 THEN 'Medium (6-15)'
            WHEN COALESCE(p.participant_count, 1) <= 50 THEN 'Large (16-50)'
            ELSE 'Very Large (>50)'
        END AS participant_size_category,
        
        -- Time of day category
        CASE 
            WHEN HOUR(m.start_time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(m.start_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(m.start_time) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night/Early Morning'
        END AS time_of_day_category,
        
        -- Day of week
        CASE DAYOFWEEK(m.start_time)
            WHEN 1 THEN 'Sunday'
            WHEN 2 THEN 'Monday'
            WHEN 3 THEN 'Tuesday'
            WHEN 4 THEN 'Wednesday'
            WHEN 5 THEN 'Thursday'
            WHEN 6 THEN 'Friday'
            WHEN 7 THEN 'Saturday'
        END AS day_of_week,
        
        -- Weekend flag
        CASE WHEN DAYOFWEEK(m.start_time) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend_meeting,
        
        -- Recurring type (simplified logic)
        CASE 
            WHEN UPPER(m.meeting_topic) LIKE '%DAILY%' OR UPPER(m.meeting_topic) LIKE '%STANDUP%' THEN TRUE
            WHEN UPPER(m.meeting_topic) LIKE '%WEEKLY%' OR UPPER(m.meeting_topic) LIKE '%RECURRING%' THEN TRUE
            ELSE FALSE
        END AS is_recurring_type,
        
        -- Meeting quality threshold (based on duration and participants)
        CASE 
            WHEN m.duration_minutes >= 30 AND COALESCE(p.participant_count, 1) >= 3 THEN 'High'
            WHEN m.duration_minutes >= 15 AND COALESCE(p.participant_count, 1) >= 2 THEN 'Medium'
            ELSE 'Low'
        END AS meeting_quality_threshold,
        
        -- Typical features used (estimated based on meeting type)
        CASE 
            WHEN UPPER(m.meeting_topic) LIKE '%DEMO%' OR UPPER(m.meeting_topic) LIKE '%PRESENTATION%' THEN 'Screen Share, Recording'
            WHEN UPPER(m.meeting_topic) LIKE '%TRAINING%' OR UPPER(m.meeting_topic) LIKE '%WORKSHOP%' THEN 'Screen Share, Breakout Rooms, Polls'
            WHEN UPPER(m.meeting_topic) LIKE '%INTERVIEW%' THEN 'Recording, Screen Share'
            WHEN UPPER(m.meeting_topic) LIKE '%SOCIAL%' THEN 'Chat, Video'
            ELSE 'Audio, Video, Chat'
        END AS typical_features_used,
        
        -- Business purpose
        CASE 
            WHEN UPPER(m.meeting_topic) LIKE '%STANDUP%' OR UPPER(m.meeting_topic) LIKE '%DAILY%' THEN 'Team Coordination'
            WHEN UPPER(m.meeting_topic) LIKE '%TRAINING%' OR UPPER(m.meeting_topic) LIKE '%WORKSHOP%' THEN 'Knowledge Transfer'
            WHEN UPPER(m.meeting_topic) LIKE '%INTERVIEW%' THEN 'Talent Acquisition'
            WHEN UPPER(m.meeting_topic) LIKE '%DEMO%' OR UPPER(m.meeting_topic) LIKE '%PRESENTATION%' THEN 'Information Sharing'
            WHEN UPPER(m.meeting_topic) LIKE '%PLANNING%' OR UPPER(m.meeting_topic) LIKE '%STRATEGY%' THEN 'Strategic Planning'
            WHEN UPPER(m.meeting_topic) LIKE '%REVIEW%' THEN 'Performance Review'
            WHEN UPPER(m.meeting_topic) LIKE '%SOCIAL%' THEN 'Team Building'
            ELSE 'General Communication'
        END AS business_purpose,
        
        -- Audit fields
        m.source_system,
        m.load_date,
        m.update_date
        
    FROM source_meetings m
    LEFT JOIN meeting_participants p ON m.meeting_id = p.meeting_id
),

meeting_type_aggregation AS (
    SELECT DISTINCT
        meeting_type,
        meeting_category,
        duration_category,
        participant_size_category,
        time_of_day_category,
        day_of_week,
        is_weekend_meeting,
        is_recurring_type,
        meeting_quality_threshold,
        typical_features_used,
        business_purpose,
        source_system,
        load_date,
        update_date
    FROM meeting_analysis
)

SELECT 
    MD5(CONCAT(
        meeting_type, '_',
        meeting_category, '_',
        duration_category, '_',
        participant_size_category, '_',
        time_of_day_category, '_',
        day_of_week
    )) AS meeting_type_id,
    meeting_type,
    meeting_category,
    duration_category,
    participant_size_category,
    time_of_day_category,
    day_of_week,
    is_weekend_meeting,
    is_recurring_type,
    meeting_quality_threshold,
    typical_features_used,
    business_purpose,
    load_date,
    update_date,
    source_system
FROM meeting_type_aggregation
ORDER BY meeting_type, meeting_category