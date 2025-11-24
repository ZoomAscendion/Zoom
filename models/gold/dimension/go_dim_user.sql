{{ config(
    materialized='table',
    unique_key='user_dim_id'
) }}

with source_users as (
    select 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
    from {{ source('silver', 'si_users') }}
    where validation_status = 'PASSED'
),

user_dimension as (
    select 
        row_number() over (order by user_id) as user_dim_id,
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
        case 
            when upper(substring(email, position('@' in email) + 1)) like '%.com' then 'North America'
            when upper(substring(email, position('@' in email) + 1)) like '%.uk' 
                or upper(substring(email, position('@' in email) + 1)) like '%.eu' then 'Europe'
            else 'Unknown'
        end as geographic_region,
        case 
            when upper(company) like '%TECH%' or upper(company) like '%SOFTWARE%' then 'Technology'
            when upper(company) like '%BANK%' or upper(company) like '%FINANCE%' then 'Financial Services'
            else 'Unknown'
        end as industry_sector,
        'Standard User' as user_role,
        case 
            when upper(plan_type) = 'FREE' then 'Individual'
            else 'Business'
        end as account_type,
        'English' as language_preference,
        current_date as effective_start_date,
        '9999-12-31'::date as effective_end_date,
        true as is_current_record,
        current_date as load_date,
        current_date as update_date,
        source_system
    from source_users
)

select * from user_dimension
