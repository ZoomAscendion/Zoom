{{ config(
    materialized='table',
    cluster_by=['meeting_type_id', 'time_of_day_category']
) }}

with source_meetings as (
    select 
        meeting_id,
        start_time,
        duration_minutes,
        data_quality_score,
        source_system
    from {{ source('silver', 'si_meetings') }}
    where validation_status = 'PASSED'
),

meeting_type_transformations as (
    select
        row_number() over (order by meeting_id) as meeting_type_id,
        'Standard Meeting' as meeting_type,
        
        -- Meeting categorization based on duration
        case 
            when duration_minutes <= 15 then 'Quick Sync'
            when duration_minutes <= 60 then 'Standard Meeting'
            when duration_minutes <= 120 then 'Extended Meeting'
            else 'Long Session'
        end as meeting_category,
        
        case 
            when duration_minutes <= 15 then 'Brief'
            when duration_minutes <= 60 then 'Standard'
            when duration_minutes <= 120 then 'Extended'
            else 'Long'
        end as duration_category,
        
        'Unknown' as participant_size_category,
        
        -- Time of day categorization
        case 
            when hour(start_time) between 6 and 11 then 'Morning'
            when hour(start_time) between 12 and 17 then 'Afternoon'
            when hour(start_time) between 18 and 21 then 'Evening'
            else 'Night'
        end as time_of_day_category,
        
        dayname(start_time) as day_of_week,
        
        case when dayofweek(start_time) in (1, 7) then true else false end as is_weekend_meeting,
        
        false as is_recurring_type,
        
        -- Meeting quality threshold
        case 
            when data_quality_score >= 90 then 9.0
            when data_quality_score >= 80 then 8.0
            when data_quality_score >= 70 then 7.0
            else 6.0
        end as meeting_quality_threshold,
        
        'Standard meeting features' as typical_features_used,
        'Business Meeting' as business_purpose,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        source_system
        
    from source_meetings
)

select * from meeting_type_transformations
