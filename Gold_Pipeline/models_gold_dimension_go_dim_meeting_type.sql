{{ config(
    materialized='table',
    schema='gold',
    tags=['dimension', 'meeting_type'],
    unique_key='meeting_type_id'
) }}

-- Meeting type dimension table for Gold layer
-- Categorizes meetings based on various characteristics

WITH source_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        LOAD_DATE,
        UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM {{ source('silver', 'SI_MEETINGS') }}
    WHERE VALIDATION_STATUS = 'VALID'
        AND DATA_QUALITY_SCORE >= 0.7
),

meeting_analysis AS (
    SELECT 
        MEETING_TOPIC,
        DURATION_MINUTES,
        START_TIME,
        
        -- Participant count analysis (from participants table)
        COUNT(DISTINCT p.USER_ID) AS participant_count,
        
        -- Feature usage analysis
        COUNT(DISTINCT f.FEATURE_NAME) AS features_used_count,
        
        SOURCE_SYSTEM
    FROM source_meetings m
    LEFT JOIN {{ source('silver', 'SI_PARTICIPANTS') }} p 
        ON m.MEETING_ID = p.MEETING_ID
        AND p.VALIDATION_STATUS = 'VALID'
    LEFT JOIN {{ source('silver', 'SI_FEATURE_USAGE') }} f 
        ON m.MEETING_ID = f.MEETING_ID
        AND f.VALIDATION_STATUS = 'VALID'
    GROUP BY 
        MEETING_TOPIC,
        DURATION_MINUTES,
        START_TIME,
        SOURCE_SYSTEM
),

meeting_type_transformations AS (
    SELECT 
        -- Generate surrogate key based on meeting characteristics
        {{ dbt_utils.generate_surrogate_key([
            'meeting_category',
            'duration_category', 
            'participant_size_category',
            'time_of_day_category',
            'day_of_week'
        ]) }} AS meeting_type_id,
        
        -- Meeting type classification based on topic
        CASE 
            WHEN UPPER(MEETING_TOPIC) LIKE '%STANDUP%' OR UPPER(MEETING_TOPIC) LIKE '%DAILY%' THEN 'Daily Standup'
            WHEN UPPER(MEETING_TOPIC) LIKE '%TRAINING%' OR UPPER(MEETING_TOPIC) LIKE '%WORKSHOP%' THEN 'Training'
            WHEN UPPER(MEETING_TOPIC) LIKE '%INTERVIEW%' OR UPPER(MEETING_TOPIC) LIKE '%HIRING%' THEN 'Interview'
            WHEN UPPER(MEETING_TOPIC) LIKE '%PRESENTATION%' OR UPPER(MEETING_TOPIC) LIKE '%DEMO%' THEN 'Presentation'
            WHEN UPPER(MEETING_TOPIC) LIKE '%REVIEW%' OR UPPER(MEETING_TOPIC) LIKE '%RETROSPECTIVE%' THEN 'Review'
            WHEN UPPER(MEETING_TOPIC) LIKE '%PLANNING%' OR UPPER(MEETING_TOPIC) LIKE '%STRATEGY%' THEN 'Planning'
            WHEN UPPER(MEETING_TOPIC) LIKE '%WEBINAR%' OR UPPER(MEETING_TOPIC) LIKE '%SEMINAR%' THEN 'Webinar'
            WHEN UPPER(MEETING_TOPIC) LIKE '%SOCIAL%' OR UPPER(MEETING_TOPIC) LIKE '%COFFEE%' THEN 'Social'
            ELSE 'General Meeting'
        END AS meeting_type,
        
        -- Meeting category
        CASE 
            WHEN UPPER(MEETING_TOPIC) LIKE '%STANDUP%' OR UPPER(MEETING_TOPIC) LIKE '%DAILY%' THEN 'Operational'
            WHEN UPPER(MEETING_TOPIC) LIKE '%TRAINING%' OR UPPER(MEETING_TOPIC) LIKE '%WORKSHOP%' THEN 'Learning'
            WHEN UPPER(MEETING_TOPIC) LIKE '%INTERVIEW%' OR UPPER(MEETING_TOPIC) LIKE '%HIRING%' THEN 'HR'
            WHEN UPPER(MEETING_TOPIC) LIKE '%PRESENTATION%' OR UPPER(MEETING_TOPIC) LIKE '%DEMO%' THEN 'Presentation'
            WHEN UPPER(MEETING_TOPIC) LIKE '%REVIEW%' OR UPPER(MEETING_TOPIC) LIKE '%RETROSPECTIVE%' THEN 'Review'
            WHEN UPPER(MEETING_TOPIC) LIKE '%PLANNING%' OR UPPER(MEETING_TOPIC) LIKE '%STRATEGY%' THEN 'Strategic'
            WHEN UPPER(MEETING_TOPIC) LIKE '%WEBINAR%' OR UPPER(MEETING_TOPIC) LIKE '%SEMINAR%' THEN 'Educational'
            WHEN UPPER(MEETING_TOPIC) LIKE '%SOCIAL%' OR UPPER(MEETING_TOPIC) LIKE '%COFFEE%' THEN 'Social'
            ELSE 'Business'
        END AS meeting_category,
        
        -- Duration categorization
        CASE 
            WHEN DURATION_MINUTES <= 15 THEN 'Quick (≤15 min)'
            WHEN DURATION_MINUTES <= 30 THEN 'Short (16-30 min)'
            WHEN DURATION_MINUTES <= 60 THEN 'Medium (31-60 min)'
            WHEN DURATION_MINUTES <= 120 THEN 'Long (61-120 min)'
            ELSE 'Extended (>120 min)'
        END AS duration_category,
        
        -- Participant size categorization
        CASE 
            WHEN participant_count = 1 THEN 'Solo'
            WHEN participant_count <= 5 THEN 'Small (2-5)'
            WHEN participant_count <= 15 THEN 'Medium (6-15)'
            WHEN participant_count <= 50 THEN 'Large (16-50)'
            ELSE 'Very Large (>50)'
        END AS participant_size_category,
        
        -- Time of day categorization
        CASE 
            WHEN EXTRACT(HOUR FROM START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night/Early Morning'
        END AS time_of_day_category,
        
        -- Day of week
        DAYNAME(START_TIME) AS day_of_week,
        
        -- Weekend meeting indicator
        CASE 
            WHEN EXTRACT(DAYOFWEEK FROM START_TIME) IN (1, 7) THEN TRUE
            ELSE FALSE
        END AS is_weekend_meeting,
        
        -- Recurring meeting type indicator (simplified)
        CASE 
            WHEN UPPER(MEETING_TOPIC) LIKE '%STANDUP%' OR 
                 UPPER(MEETING_TOPIC) LIKE '%DAILY%' OR 
                 UPPER(MEETING_TOPIC) LIKE '%WEEKLY%' OR
                 UPPER(MEETING_TOPIC) LIKE '%RECURRING%' THEN TRUE
            ELSE FALSE
        END AS is_recurring_type,
        
        -- Meeting quality threshold based on duration and participants
        CASE 
            WHEN DURATION_MINUTES >= 30 AND participant_count >= 3 THEN 'High'
            WHEN DURATION_MINUTES >= 15 AND participant_count >= 2 THEN 'Medium'
            ELSE 'Low'
        END AS meeting_quality_threshold,
        
        -- Typical features used (based on meeting type)
        CASE 
            WHEN UPPER(MEETING_TOPIC) LIKE '%PRESENTATION%' OR UPPER(MEETING_TOPIC) LIKE '%DEMO%' 
                THEN 'Screen Share, Recording, Chat'
            WHEN UPPER(MEETING_TOPIC) LIKE '%TRAINING%' OR UPPER(MEETING_TOPIC) LIKE '%WORKSHOP%' 
                THEN 'Screen Share, Recording, Breakout Rooms, Polls'
            WHEN UPPER(MEETING_TOPIC) LIKE '%INTERVIEW%' 
                THEN 'Video, Audio, Recording'
            WHEN UPPER(MEETING_TOPIC) LIKE '%STANDUP%' OR UPPER(MEETING_TOPIC) LIKE '%DAILY%' 
                THEN 'Video, Audio, Chat'
            ELSE 'Video, Audio, Chat, Screen Share'
        END AS typical_features_used,
        
        -- Business purpose
        CASE 
            WHEN UPPER(MEETING_TOPIC) LIKE '%STANDUP%' OR UPPER(MEETING_TOPIC) LIKE '%DAILY%' THEN 'Team Coordination'
            WHEN UPPER(MEETING_TOPIC) LIKE '%TRAINING%' OR UPPER(MEETING_TOPIC) LIKE '%WORKSHOP%' THEN 'Skill Development'
            WHEN UPPER(MEETING_TOPIC) LIKE '%INTERVIEW%' THEN 'Talent Acquisition'
            WHEN UPPER(MEETING_TOPIC) LIKE '%PRESENTATION%' OR UPPER(MEETING_TOPIC) LIKE '%DEMO%' THEN 'Information Sharing'
            WHEN UPPER(MEETING_TOPIC) LIKE '%REVIEW%' OR UPPER(MEETING_TOPIC) LIKE '%RETROSPECTIVE%' THEN 'Performance Review'
            WHEN UPPER(MEETING_TOPIC) LIKE '%PLANNING%' OR UPPER(MEETING_TOPIC) LIKE '%STRATEGY%' THEN 'Strategic Planning'
            WHEN UPPER(MEETING_TOPIC) LIKE '%SOCIAL%' THEN 'Team Building'
            ELSE 'General Business'
        END AS business_purpose,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        SOURCE_SYSTEM AS source_system
        
    FROM meeting_analysis
)

-- Create distinct meeting types
SELECT DISTINCT
    meeting_type_id,
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
FROM meeting_type_transformations
ORDER BY meeting_type, meeting_category