{{ config(
    materialized='table'
) }}

-- Meeting type dimension derived from meeting characteristics
-- Categorizes meetings by duration, time, and participant patterns

WITH source_meetings AS (
    SELECT 
        duration_minutes,
        start_time,
        source_system
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = 'PASSED'
      AND duration_minutes IS NOT NULL
      AND start_time IS NOT NULL
),

meeting_categories AS (
    SELECT DISTINCT
        CASE 
            WHEN duration_minutes <= 15 THEN 'Quick Sync'
            WHEN duration_minutes <= 60 THEN 'Standard Meeting'
            WHEN duration_minutes <= 120 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END AS meeting_category,
        CASE 
            WHEN duration_minutes <= 15 THEN 'Brief'
            WHEN duration_minutes <= 60 THEN 'Standard'
            WHEN duration_minutes <= 120 THEN 'Extended'
            ELSE 'Long'
        END AS duration_category,
        CASE 
            WHEN HOUR(start_time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(start_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(start_time) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day_category,
        DAYNAME(start_time) AS day_of_week,
        CASE WHEN DAYOFWEEK(start_time) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend_meeting,
        source_system
    FROM source_meetings
),

transformed_meeting_types AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY meeting_category, duration_category, time_of_day_category) AS meeting_type_id,
        'Standard Meeting' AS meeting_type,
        meeting_category,
        duration_category,
        'Unknown' AS participant_size_category,  -- To be enhanced with participant data
        time_of_day_category,
        day_of_week,
        is_weekend_meeting,
        FALSE AS is_recurring_type,  -- To be enhanced with recurring meeting logic
        CASE 
            WHEN duration_category = 'Brief' THEN 7.0
            WHEN duration_category = 'Standard' THEN 8.0
            WHEN duration_category = 'Extended' THEN 7.5
            ELSE 7.0
        END AS meeting_quality_threshold,
        CASE 
            WHEN meeting_category = 'Quick Sync' THEN 'Screen Share, Chat'
            WHEN meeting_category = 'Standard Meeting' THEN 'Screen Share, Chat, Recording'
            WHEN meeting_category = 'Extended Meeting' THEN 'Screen Share, Chat, Recording, Breakout Rooms'
            ELSE 'All Features'
        END AS typical_features_used,
        CASE 
            WHEN time_of_day_category = 'Morning' THEN 'Daily Standup'
            WHEN time_of_day_category = 'Afternoon' THEN 'Business Meeting'
            WHEN time_of_day_category = 'Evening' THEN 'Training Session'
            ELSE 'Ad-hoc Meeting'
        END AS business_purpose,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM meeting_categories
)

SELECT * FROM transformed_meeting_types
