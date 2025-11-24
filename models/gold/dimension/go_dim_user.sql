{{ config(
    materialized='table'
) }}

with source_data as (
    select 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_date,
        source_system,
        validation_status
    from {{ source('silver', 'si_users') }}
    where validation_status = 'PASSED'
),

transformed as (
    select
        user_id,
        initcap(trim(user_name)) as user_name,
        upper(substring(email, position('@' in email) + 1)) as email_domain,
        initcap(trim(company)) as company,
        case 
            when upper(plan_type) in ('FREE', 'BASIC') then 'Basic'
            when upper(plan_type) in ('PRO', 'PROFESSIONAL') then 'Pro'
            when upper(plan_type) in ('BUSINESS', 'ENTERPRISE') then 'Enterprise'
            else 'Unknown'
        end as plan_type,
        case 
            when upper(plan_type) = 'FREE' then 'Free'
            else 'Paid'
        end as plan_category,
        load_date as registration_date,
        case 
            when validation_status = 'PASSED' then 'Active'
            else 'Inactive'
        end as user_status,
        'Unknown' as geographic_region,
        'Unknown' as industry_sector,
        'Standard User' as user_role,
        case 
            when upper(plan_type) = 'FREE' then 'Individual'
            else 'Business'
        end as account_type,
        'English' as language_preference,
        current_date as effective_start_date,
        '9999-12-31'::date as effective_end_date,
        true as is_current_record,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        source_system
    from source_data
)

select * from transformed
