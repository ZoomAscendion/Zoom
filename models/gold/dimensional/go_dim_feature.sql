{{ config(
    materialized='table',
    unique_key='feature_id'
) }}

with source_features as (
    select distinct
        feature_name,
        source_system
    from {{ source('silver', 'si_feature_usage') }}
    where validation_status = 'PASSED'
      and feature_name is not null
),

feature_dimension as (
    select
        initcap(trim(feature_name)) as feature_name,
        case 
            when upper(feature_name) like '%SCREEN%SHARE%' then 'Collaboration'
            when upper(feature_name) like '%RECORD%' then 'Recording'
            when upper(feature_name) like '%CHAT%' then 'Communication'
            when upper(feature_name) like '%BREAKOUT%' then 'Advanced Meeting'
            when upper(feature_name) like '%POLL%' then 'Engagement'
            else 'General'
        end as feature_category,
        case 
            when upper(feature_name) like '%BASIC%' then 'Core'
            when upper(feature_name) like '%ADVANCED%' then 'Advanced'
            else 'Standard'
        end as feature_type,
        case 
            when upper(feature_name) like '%BREAKOUT%' or upper(feature_name) like '%POLL%' then 'High'
            when upper(feature_name) like '%RECORD%' then 'Medium'
            else 'Low'
        end as feature_complexity,
        case 
            when upper(feature_name) like '%RECORD%' or upper(feature_name) like '%BREAKOUT%' then true
            else false
        end as is_premium_feature,
        '2020-01-01'::date as feature_release_date,
        'Active' as feature_status,
        'Medium' as usage_frequency_category,
        'Feature usage tracking for ' || feature_name as feature_description,
        'All Users' as target_user_segment,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        source_system
    from source_features
)

select * from feature_dimension
