{{ config(
    materialized='table'
) }}

with feature_usage as (
    select 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        source_system,
        validation_status
    from {{ source('silver', 'si_feature_usage') }}
    where validation_status = 'PASSED'
),

meetings as (
    select 
        meeting_id,
        host_id,
        duration_minutes
    from {{ source('silver', 'si_meetings') }}
    where validation_status = 'PASSED'
),

transformed as (
    select
        f.usage_date as usage_date,
        f.feature_name,
        f.meeting_id,
        f.usage_date::timestamp_ntz as usage_timestamp,
        f.usage_count,
        coalesce(m.duration_minutes, 0) as usage_duration_minutes,
        coalesce(m.duration_minutes, 0) as session_duration_minutes,
        case 
            when f.usage_count >= 10 then 5.0
            when f.usage_count >= 5 then 4.0
            when f.usage_count >= 3 then 3.0
            when f.usage_count >= 1 then 2.0
            else 1.0
        end as feature_adoption_score,
        case 
            when f.usage_count > 0 then 5.0
            else 1.0
        end as user_experience_rating,
        case 
            when f.usage_count > 0 then 5.0
            else 1.0
        end as feature_performance_score,
        1 as concurrent_features_count,
        case 
            when coalesce(m.duration_minutes, 0) >= 60 then 'Extended Session'
            when coalesce(m.duration_minutes, 0) >= 30 then 'Standard Session'
            when coalesce(m.duration_minutes, 0) >= 15 then 'Short Session'
            when coalesce(m.duration_minutes, 0) >= 5 then 'Brief Session'
            else 'Quick Access'
        end as usage_context,
        'Desktop' as device_type,
        'Latest' as platform_version,
        0 as error_count,
        case 
            when f.usage_count > 0 then 100.0
            else 0.0
        end as success_rate,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        f.source_system
    from feature_usage f
    left join meetings m on f.meeting_id = m.meeting_id
)

select * from transformed
