{{ config(
    materialized='table',
    cluster_by=['license_id', 'license_category']
) }}

-- Create sample license dimension
with sample_licenses as (
    select
        1 as license_id,
        'Basic' as license_type,
        'Standard' as license_category,
        'Tier 1' as license_tier,
        100 as max_participants,
        5 as storage_limit_gb,
        40 as recording_limit_hours,
        false as admin_features_included,
        false as api_access_included,
        false as sso_support_included,
        14.99 as monthly_price,
        149.90 as annual_price,
        'Standard license benefits for Basic plan' as license_benefits,
        '2020-01-01'::date as effective_start_date,
        '9999-12-31'::date as effective_end_date,
        true as is_current_record,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as license_id,
        'Pro' as license_type,
        'Professional' as license_category,
        'Tier 2' as license_tier,
        500 as max_participants,
        100 as storage_limit_gb,
        100 as recording_limit_hours,
        false as admin_features_included,
        true as api_access_included,
        false as sso_support_included,
        19.99 as monthly_price,
        199.90 as annual_price,
        'Standard license benefits for Pro plan' as license_benefits,
        '2020-01-01'::date as effective_start_date,
        '9999-12-31'::date as effective_end_date,
        true as is_current_record,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        3 as license_id,
        'Enterprise' as license_type,
        'Enterprise' as license_category,
        'Tier 3' as license_tier,
        1000 as max_participants,
        1000 as storage_limit_gb,
        500 as recording_limit_hours,
        true as admin_features_included,
        true as api_access_included,
        true as sso_support_included,
        39.99 as monthly_price,
        399.90 as annual_price,
        'Standard license benefits for Enterprise plan' as license_benefits,
        '2020-01-01'::date as effective_start_date,
        '9999-12-31'::date as effective_end_date,
        true as is_current_record,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_licenses
