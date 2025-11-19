{{ config(
    materialized='table',
    cluster_by=['date_id', 'feature_id']
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

fact_feature_usage as (
    select
        row_number() over (order by sfu.usage_id) as feature_usage_id,
        
        -- Foreign keys to dimensions
        dd.date_id,
        df.feature_id,
        du.user_dim_id,
        
        -- Usage identifiers
        sfu.meeting_id,
        sfu.usage_date,
        sfu.usage_date::timestamp_ntz as usage_timestamp,
        sfu.feature_name,
        
        -- Usage metrics
        sfu.usage_count,
        coalesce(sm.duration_minutes, 0) as usage_duration_minutes,
        coalesce(sm.duration_minutes, 0) as session_duration_minutes,
        
        -- Calculated metrics
        case 
            when sfu.usage_count >= 10 then 5.0
            when sfu.usage_count >= 5 then 4.0
            when sfu.usage_count >= 3 then 3.0
            when sfu.usage_count >= 1 then 2.0
            else 1.0
        end as feature_adoption_score,
        
        4.0 as user_experience_rating, -- Placeholder
        5.0 as feature_performance_score, -- Placeholder
        1 as concurrent_features_count, -- Placeholder
        
        -- Usage context
        case 
            when coalesce(sm.duration_minutes, 0) >= 60 then 'Extended Session'
            when coalesce(sm.duration_minutes, 0) >= 30 then 'Standard Session'
            when coalesce(sm.duration_minutes, 0) >= 15 then 'Short Session'
            when coalesce(sm.duration_minutes, 0) >= 5 then 'Brief Session'
            else 'Quick Access'
        end as usage_context,
        
        'Desktop' as device_type, -- Placeholder
        'Latest' as platform_version, -- Placeholder
        0 as error_count, -- Placeholder
        100.0 as success_rate, -- Placeholder
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        sfu.source_system
        
    from source_feature_usage sfu
    join {{ ref('dim_date') }} dd on sfu.usage_date = dd.date_value
    join {{ ref('dim_feature') }} df on sfu.feature_name = df.feature_name
    left join source_meetings sm on sfu.meeting_id = sm.meeting_id
    left join {{ ref('dim_user') }} du on sm.host_id = du.user_id and du.is_current_record = true
)

select * from fact_feature_usage
