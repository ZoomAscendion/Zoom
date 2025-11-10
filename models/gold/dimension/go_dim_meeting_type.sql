{{ config(
    materialized='table',
    cluster_by=['MEETING_CATEGORY', 'LOAD_DATE'],
    tags=['dimension', 'meeting_type']
) }}

-- Meeting type dimension derived from meeting patterns and characteristics
-- Contains meeting classifications for analytical purposes

WITH meeting_patterns AS (
    SELECT DISTINCT
        CASE 
            WHEN duration_minutes <= 15 THEN 'Quick Meeting'
            WHEN duration_minutes <= 60 THEN 'Standard Meeting'
            WHEN duration_minutes <= 180 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END AS meeting_type,
        
        CASE 
            WHEN duration_minutes <= 15 THEN 'Short'
            WHEN duration_minutes <= 60 THEN 'Medium'
            WHEN duration_minutes <= 180 THEN 'Long'
            ELSE 'Extended'
        END AS duration_category
        
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
        AND duration_minutes > 0
),

participant_patterns AS (
    SELECT DISTINCT
        CASE 
            WHEN participant_count <= 2 THEN 'One-on-One'
            WHEN participant_count <= 10 THEN 'Small Group'
            WHEN participant_count <= 50 THEN 'Medium Group'
            WHEN participant_count <= 100 THEN 'Large Group'
            ELSE 'Webinar'
        END AS meeting_type,
        
        CASE 
            WHEN participant_count <= 2 THEN 'Personal'
            WHEN participant_count <= 10 THEN 'Small'
            WHEN participant_count <= 50 THEN 'Medium'
            WHEN participant_count <= 100 THEN 'Large'
            ELSE 'Mass'
        END AS participant_size_category
        
    FROM (
        SELECT 
            m.meeting_id,
            COUNT(p.participant_id) AS participant_count
        FROM {{ source('silver', 'si_meetings') }} m
        LEFT JOIN {{ source('silver', 'si_participants') }} p ON m.meeting_id = p.meeting_id
        WHERE m.validation_status = {{ var('validation_status_filter') }}
            AND m.data_quality_score >= {{ var('data_quality_threshold') }}
        GROUP BY m.meeting_id
    ) participant_counts
),

time_patterns AS (
    SELECT DISTINCT
        CASE 
            WHEN HOUR(start_time) BETWEEN 6 AND 11 THEN 'Morning Meeting'
            WHEN HOUR(start_time) BETWEEN 12 AND 17 THEN 'Afternoon Meeting'
            WHEN HOUR(start_time) BETWEEN 18 AND 22 THEN 'Evening Meeting'
            ELSE 'Off-Hours Meeting'
        END AS meeting_type,
        
        CASE 
            WHEN HOUR(start_time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(start_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(start_time) BETWEEN 18 AND 22 THEN 'Evening'
            ELSE 'Off-Hours'
        END AS time_of_day_category
        
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
),

all_meeting_types AS (
    -- Combine all meeting type patterns
    SELECT 'Instant Meeting' AS meeting_type, 'Instant' AS meeting_category, 'Short' AS duration_category, 'Small' AS participant_size_category, 'Any' AS time_of_day_category
    UNION ALL
    SELECT 'Scheduled Meeting' AS meeting_type, 'Scheduled' AS meeting_category, 'Medium' AS duration_category, 'Medium' AS participant_size_category, 'Business Hours' AS time_of_day_category
    UNION ALL
    SELECT 'Recurring Meeting' AS meeting_type, 'Recurring' AS meeting_category, 'Medium' AS duration_category, 'Small' AS participant_size_category, 'Business Hours' AS time_of_day_category
    UNION ALL
    SELECT 'Webinar' AS meeting_type, 'Webinar' AS meeting_category, 'Long' AS duration_category, 'Mass' AS participant_size_category, 'Business Hours' AS time_of_day_category
    UNION ALL
    SELECT 'Training Session' AS meeting_type, 'Training' AS meeting_category, 'Extended' AS duration_category, 'Medium' AS participant_size_category, 'Business Hours' AS time_of_day_category
    UNION ALL
    SELECT 'All Hands' AS meeting_type, 'Company' AS meeting_category, 'Medium' AS duration_category, 'Large' AS participant_size_category, 'Business Hours' AS time_of_day_category
    UNION ALL
    SELECT 'Interview' AS meeting_type, 'HR' AS meeting_category, 'Short' AS duration_category, 'Personal' AS participant_size_category, 'Business Hours' AS time_of_day_category
    UNION ALL
    SELECT 'Client Meeting' AS meeting_type, 'External' AS meeting_category, 'Medium' AS duration_category, 'Small' AS participant_size_category, 'Business Hours' AS time_of_day_category
),

meeting_type_enrichment AS (
    SELECT 
        meeting_type,
        meeting_category,
        duration_category,
        participant_size_category,
        time_of_day_category,
        
        -- Recurring type indicator
        CASE 
            WHEN meeting_type IN ('Recurring Meeting', 'Training Session', 'All Hands') THEN TRUE
            ELSE FALSE
        END AS is_recurring_type,
        
        -- Registration requirement
        CASE 
            WHEN meeting_type IN ('Webinar', 'Training Session', 'All Hands') THEN TRUE
            ELSE FALSE
        END AS requires_registration,
        
        -- Recording support
        CASE 
            WHEN meeting_type IN ('Webinar', 'Training Session', 'All Hands', 'Client Meeting') THEN TRUE
            ELSE FALSE
        END AS supports_recording,
        
        -- Maximum participants allowed
        CASE 
            WHEN meeting_type = 'Webinar' THEN 10000
            WHEN meeting_type IN ('All Hands', 'Training Session') THEN 1000
            WHEN meeting_type IN ('Client Meeting', 'Scheduled Meeting') THEN 500
            WHEN meeting_type = 'Recurring Meeting' THEN 100
            WHEN meeting_type IN ('Interview', 'Instant Meeting') THEN 25
            ELSE 100
        END AS max_participants_allowed,
        
        -- Security level
        CASE 
            WHEN meeting_type IN ('Interview', 'Client Meeting') THEN 'High'
            WHEN meeting_type IN ('All Hands', 'Training Session') THEN 'Medium'
            ELSE 'Standard'
        END AS security_level,
        
        -- Meeting format
        CASE 
            WHEN meeting_type = 'Webinar' THEN 'Broadcast'
            WHEN meeting_type IN ('Training Session', 'All Hands') THEN 'Presentation'
            WHEN meeting_type IN ('Interview', 'Client Meeting') THEN 'Discussion'
            ELSE 'Collaborative'
        END AS meeting_format
        
    FROM all_meeting_types
),

final_dimension AS (
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
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'SYSTEM_GENERATED' AS source_system
        
    FROM meeting_type_enrichment
)

SELECT * FROM final_dimension
ORDER BY meeting_category, meeting_type
