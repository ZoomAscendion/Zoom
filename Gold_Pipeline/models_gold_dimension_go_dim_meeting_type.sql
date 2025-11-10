/*
  go_dim_meeting_type.sql
  Zoom Platform Analytics System - Meeting Type Dimension
  
  Author: Data Engineering Team
  Description: Meeting type dimension for categorizing meetings based on characteristics
  
  This model creates a meeting type dimension based on meeting patterns,
  duration, participant count, and scheduling characteristics.
*/

{{ config(
    materialized='table',
    tags=['dimension', 'meeting_type'],
    cluster_by=['meeting_category', 'duration_category']
) }}

-- Analyze meeting patterns from source data
WITH meeting_analysis AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        
        -- Derive meeting characteristics
        CASE 
            WHEN duration_minutes <= 15 THEN 'Quick'
            WHEN duration_minutes <= 60 THEN 'Standard'
            WHEN duration_minutes <= 180 THEN 'Extended'
            ELSE 'Marathon'
        END AS duration_category,
        
        -- Time of day categorization
        CASE 
            WHEN HOUR(start_time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(start_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(start_time) BETWEEN 18 AND 22 THEN 'Evening'
            ELSE 'Off Hours'
        END AS time_of_day_category,
        
        -- Meeting topic analysis for type detection
        UPPER(COALESCE(meeting_topic, 'UNTITLED')) AS meeting_topic_upper,
        
        source_system,
        load_date,
        update_date
        
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
        AND duration_minutes > 0
),

-- Get participant counts per meeting
meeting_participants AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ source('silver', 'si_participants') }}
    WHERE validation_status = 'PASSED'
    GROUP BY meeting_id
),

-- Combine meeting data with participant counts
meeting_with_participants AS (
    SELECT 
        m.*,
        COALESCE(p.participant_count, 1) AS participant_count,
        
        -- Participant size categorization
        CASE 
            WHEN COALESCE(p.participant_count, 1) = 1 THEN 'Solo'
            WHEN COALESCE(p.participant_count, 1) <= 5 THEN 'Small'
            WHEN COALESCE(p.participant_count, 1) <= 25 THEN 'Medium'
            WHEN COALESCE(p.participant_count, 1) <= 100 THEN 'Large'
            ELSE 'Very Large'
        END AS participant_size_category
        
    FROM meeting_analysis m
    LEFT JOIN meeting_participants p ON m.meeting_id = p.meeting_id
),

-- Derive meeting types based on patterns
meeting_type_derivation AS (
    SELECT 
        -- Derive meeting type from topic and characteristics
        CASE 
            WHEN meeting_topic_upper LIKE '%WEBINAR%' THEN 'Webinar'
            WHEN meeting_topic_upper LIKE '%TRAINING%' OR meeting_topic_upper LIKE '%WORKSHOP%' THEN 'Training Session'
            WHEN meeting_topic_upper LIKE '%INTERVIEW%' THEN 'Interview'
            WHEN meeting_topic_upper LIKE '%DEMO%' OR meeting_topic_upper LIKE '%PRESENTATION%' THEN 'Presentation'
            WHEN meeting_topic_upper LIKE '%STANDUP%' OR meeting_topic_upper LIKE '%DAILY%' THEN 'Daily Standup'
            WHEN meeting_topic_upper LIKE '%REVIEW%' OR meeting_topic_upper LIKE '%RETROSPECTIVE%' THEN 'Review Meeting'
            WHEN meeting_topic_upper LIKE '%PLANNING%' THEN 'Planning Session'
            WHEN meeting_topic_upper LIKE '%SOCIAL%' OR meeting_topic_upper LIKE '%COFFEE%' THEN 'Social Meeting'
            WHEN duration_category = 'Quick' AND participant_size_category = 'Small' THEN 'Quick Sync'
            WHEN duration_category = 'Extended' AND participant_size_category IN ('Large', 'Very Large') THEN 'Town Hall'
            WHEN participant_size_category = 'Solo' THEN 'Personal Meeting'
            WHEN participant_count = 2 THEN 'One-on-One'
            ELSE 'Regular Meeting'
        END AS meeting_type,
        
        duration_category,
        participant_size_category,
        time_of_day_category,
        participant_count,
        
        -- Meeting category
        CASE 
            WHEN meeting_topic_upper LIKE '%WEBINAR%' THEN 'Broadcast'
            WHEN meeting_topic_upper LIKE '%TRAINING%' OR meeting_topic_upper LIKE '%WORKSHOP%' THEN 'Educational'
            WHEN meeting_topic_upper LIKE '%INTERVIEW%' THEN 'Recruitment'
            WHEN meeting_topic_upper LIKE '%DEMO%' OR meeting_topic_upper LIKE '%PRESENTATION%' THEN 'Presentation'
            WHEN meeting_topic_upper LIKE '%SOCIAL%' OR meeting_topic_upper LIKE '%COFFEE%' THEN 'Social'
            WHEN participant_count <= 2 THEN 'Personal'
            WHEN participant_count <= 10 THEN 'Team'
            ELSE 'Organizational'
        END AS meeting_category,
        
        source_system,
        load_date,
        update_date
        
    FROM meeting_with_participants
),

-- Create unique meeting types with their characteristics
unique_meeting_types AS (
    SELECT DISTINCT
        meeting_type,
        meeting_category,
        duration_category,
        participant_size_category,
        time_of_day_category,
        
        -- Derive additional attributes
        CASE 
            WHEN meeting_type LIKE '%Daily%' OR meeting_type LIKE '%Standup%' THEN TRUE
            WHEN meeting_type LIKE '%Weekly%' OR meeting_type LIKE '%Review%' THEN TRUE
            ELSE FALSE
        END AS is_recurring_type,
        
        CASE 
            WHEN meeting_type IN ('Webinar', 'Training Session', 'Town Hall') THEN TRUE
            ELSE FALSE
        END AS requires_registration,
        
        CASE 
            WHEN meeting_type IN ('Webinar', 'Training Session', 'Presentation', 'Interview') THEN TRUE
            WHEN duration_category IN ('Extended', 'Marathon') THEN TRUE
            ELSE FALSE
        END AS supports_recording,
        
        -- Maximum participants allowed based on type
        CASE 
            WHEN meeting_type = 'Personal Meeting' THEN 1
            WHEN meeting_type = 'One-on-One' THEN 2
            WHEN meeting_type IN ('Quick Sync', 'Daily Standup') THEN 10
            WHEN meeting_type IN ('Regular Meeting', 'Review Meeting') THEN 25
            WHEN meeting_type IN ('Training Session', 'Presentation') THEN 100
            WHEN meeting_type IN ('Webinar', 'Town Hall') THEN 1000
            ELSE 25
        END AS max_participants_allowed,
        
        -- Security level
        CASE 
            WHEN meeting_type = 'Interview' THEN 'High'
            WHEN meeting_type IN ('Training Session', 'Webinar') THEN 'Medium'
            WHEN meeting_type = 'Social Meeting' THEN 'Low'
            ELSE 'Standard'
        END AS security_level,
        
        -- Meeting format
        CASE 
            WHEN meeting_type IN ('Webinar', 'Town Hall') THEN 'Broadcast'
            WHEN meeting_type IN ('Training Session', 'Presentation') THEN 'Presentation'
            WHEN meeting_type = 'Interview' THEN 'Interview'
            WHEN meeting_type IN ('Quick Sync', 'Daily Standup') THEN 'Standup'
            ELSE 'Discussion'
        END AS meeting_format,
        
        MIN(load_date) AS load_date,
        MAX(update_date) AS update_date,
        source_system
        
    FROM meeting_type_derivation
    GROUP BY 
        meeting_type, meeting_category, duration_category, 
        participant_size_category, time_of_day_category, source_system
),

-- Final dimension with surrogate key
final_dimension AS (
    SELECT 
        -- Generate surrogate key
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
        load_date,
        update_date,
        source_system
        
    FROM unique_meeting_types
)

SELECT 
    meeting_type_id,
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
    load_date,
    update_date,
    source_system
FROM final_dimension
ORDER BY meeting_type_id