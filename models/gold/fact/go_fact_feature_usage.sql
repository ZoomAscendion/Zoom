{{ config(
    materialized='table',
    unique_key='feature_usage_id'
) }}

with source_feature_usage as (
    select 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system
    from {{ source('silver', 'si_feature_usage') }}
    where validation_status = 'PASSED'
),

feature_usage_fact as (
    select 
        row_number() over (order by fu.usage_id) as feature_usage_id,
        dd.date_id as date_id,
        df.feature_id as feature_id,
        du.user_dim_id as user_dim_id,
        fu.meeting_id,
        fu.usage_date,
        fu.usage_date::timestamp_ntz as usage_timestamp,
        fu.feature_name,
        fu.usage_count,
        coalesce(sm.duration_minutes, 0) as usage_duration_minutes,
        coalesce(sm.duration_minutes, 0) as session_duration_minutes,
        case 
            when fu.usage_count >= 10 then 5.0
            when fu.usage_count >= 5 then 4.0
            when fu.usage_count >= 3 then 3.0
            when fu.usage_count >= 1 then 2.0
            else 1.0
        end as feature_adoption_score,
        case 
            when fu.usage_count >= 5 then 5.0
            when fu.usage_count >= 3 then 4.0
            when fu.usage_count >= 2 then 3.0
            when fu.usage_count >= 1 then 2.0
            else 1.0
        end as user_experience_rating,
        case 
            when fu.usage_count > 0 then 5.0
            else 1.0
        end as feature_performance_score,
        1 as concurrent_features_count,
        case 
            when coalesce(sm.duration_minutes, 0) >= 60 then 'Extended Session'
            when coalesce(sm.duration_minutes, 0) >= 30 then 'Standard Session'
            when coalesce(sm.duration_minutes, 0) >= 15 then 'Short Session'
            when coalesce(sm.duration_minutes, 0) >= 5 then 'Brief Session'
            else 'Quick Access'
        end as usage_context,
        'Desktop' as device_type,
        'v1.0' as platform_version,
        0 as error_count,
        case 
            when fu.usage_count > 0 then 100.0
            else 0.0
        end as success_rate,
        current_date as load_date,
        current_date as update_date,
        fu.source_system
    from source_feature_usage fu
    left join {{ source('silver', 'si_meetings') }} sm on fu.meeting_id = sm.meeting_id
    left join {{ ref('go_dim_date') }} dd on fu.usage_date = dd.date_value
    left join {{ ref('go_dim_feature') }} df on fu.feature_name = df.feature_name
    left join {{ source('silver', 'si_users') }} su on sm.host_id = su.user_id
    left join {{ ref('go_dim_user') }} du on su.user_id = du.user_id
)

select * from feature_usage_fact
