{{ config(
    materialized='table',
    unique_key='feature_usage_id'
) }}

with source_feature_usage as (
    select *
    from {{ source('silver', 'si_feature_usage') }}
    where validation_status = 'PASSED'
),

source_meetings as (
    select *
    from {{ source('silver', 'si_meetings') }}
    where validation_status = 'PASSED'
),

feature_usage_fact as (
    select
        dd.date_id as date_id,
        df.feature_id as feature_id,
        du.user_dim_id as user_dim_id,
        sfu.meeting_id,
        sfu.usage_date,
        sfu.usage_date::timestamp_ntz as usage_timestamp,
        sfu.feature_name,
        sfu.usage_count,
        coalesce(sm.duration_minutes, 0) as usage_duration_minutes,
        coalesce(sm.duration_minutes, 0) as session_duration_minutes,
        case 
            when sfu.usage_count >= 10 then 5.0
            when sfu.usage_count >= 5 then 4.0
            when sfu.usage_count >= 3 then 3.0
            when sfu.usage_count >= 1 then 2.0
            else 1.0
        end as feature_adoption_score,
        case 
            when sfu.usage_count >= 10 then 5.0
            when sfu.usage_count >= 5 then 4.0
            when sfu.usage_count >= 3 then 3.0
            when sfu.usage_count >= 1 then 2.0
            else 1.0
        end as user_experience_rating,
        case 
            when sfu.usage_count > 0 then 5.0
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
        'Latest' as platform_version,
        0 as error_count,
        case 
            when sfu.usage_count > 0 then 100.0
            else 0.0
        end as success_rate,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        sfu.source_system
    from source_feature_usage sfu
    join {{ ref('go_dim_date') }} dd on sfu.usage_date = dd.date_value
    join {{ ref('go_dim_feature') }} df on sfu.feature_name = df.feature_name
    left join source_meetings sm on sfu.meeting_id = sm.meeting_id
    left join {{ ref('go_dim_user') }} du on sm.host_id = du.user_id and du.is_current_record = true
)

select * from feature_usage_fact
