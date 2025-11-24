{{ config(
    materialized='table'
) }}

with source_data as (
    select distinct
        license_type,
        start_date,
        end_date,
        source_system,
        validation_status
    from {{ source('silver', 'si_licenses') }}
    where validation_status = 'PASSED'
),

transformed as (
    select
        initcap(trim(license_type)) as license_type,
        case 
            when upper(license_type) like '%BASIC%' then 'Standard'
            when upper(license_type) like '%PRO%' then 'Professional'
            when upper(license_type) like '%ENTERPRISE%' then 'Enterprise'
            else 'Other'
        end as license_category,
        case 
            when upper(license_type) like '%BASIC%' then 'Tier 1'
            when upper(license_type) like '%PRO%' then 'Tier 2'
            when upper(license_type) like '%ENTERPRISE%' then 'Tier 3'
            else 'Tier 0'
        end as license_tier,
        case 
            when upper(license_type) like '%BASIC%' then 100
            when upper(license_type) like '%PRO%' then 500
            when upper(license_type) like '%ENTERPRISE%' then 1000
            else 50
        end as max_participants,
        case 
            when upper(license_type) like '%BASIC%' then 5
            when upper(license_type) like '%PRO%' then 100
            when upper(license_type) like '%ENTERPRISE%' then 1000
            else 1
        end as storage_limit_gb,
        case 
            when upper(license_type) like '%BASIC%' then 40
            when upper(license_type) like '%PRO%' then 100
            when upper(license_type) like '%ENTERPRISE%' then 500
            else 0
        end as recording_limit_hours,
        case 
            when upper(license_type) like '%ENTERPRISE%' then true
            else false
        end as admin_features_included,
        case 
            when upper(license_type) like '%PRO%' or upper(license_type) like '%ENTERPRISE%' then true
            else false
        end as api_access_included,
        case 
            when upper(license_type) like '%ENTERPRISE%' then true
            else false
        end as sso_support_included,
        case 
            when upper(license_type) like '%BASIC%' then 14.99
            when upper(license_type) like '%PRO%' then 19.99
            when upper(license_type) like '%ENTERPRISE%' then 39.99
            else 0.00
        end as monthly_price,
        case 
            when upper(license_type) like '%BASIC%' then 149.90
            when upper(license_type) like '%PRO%' then 199.90
            when upper(license_type) like '%ENTERPRISE%' then 399.90
            else 0.00
        end as annual_price,
        'Standard license benefits for ' || license_type as license_benefits,
        start_date as effective_start_date,
        end_date as effective_end_date,
        true as is_current_record,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        source_system
    from source_data
)

select * from transformed
