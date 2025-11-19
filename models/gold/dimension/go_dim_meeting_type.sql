{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_dim_meeting_type', 'SI_MEETINGS', 'go_dim_meeting_type', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_dim_meeting_type' AND process_status = 'STARTED'"
) }}

-- Meeting type dimension
WITH meeting_categories AS (
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
    FROM {{ source('silver', 'si_meetings') }}
    WHERE duration_minutes IS NOT NULL
      AND start_time IS NOT NULL
),

transformed_meeting_types AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY meeting_category, duration_category, time_of_day_category) AS meeting_type_id,
        'Standard Meeting' AS meeting_type,
        meeting_category,
        duration_category,
        'Unknown' AS participant_size_category,
        time_of_day_category,
        day_of_week,
        is_weekend_meeting,
        FALSE AS is_recurring_type,
        8.0 AS meeting_quality_threshold,
        'Standard meeting features' AS typical_features_used,
        'Business Meeting' AS business_purpose,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM meeting_categories
)

SELECT * FROM transformed_meeting_types
