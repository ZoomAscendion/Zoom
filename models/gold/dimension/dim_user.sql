{{ config(
    materialized='table',
    cluster_by=['user_dim_id', 'effective_start_date']
) }}

-- Create a simple user dimension with sample data if Silver tables don't exist
with sample_users as (
    select
        1 as user_dim_id,
        'USER001' as user_id,
        'John Doe' as user_name,
        'example.com' as email_domain,
        'Acme Corp' as company,
        'Pro' as plan_type,
        'Paid' as plan_category,
        current_date as registration_date,
        'Active' as user_status,
        'North America' as geographic_region,
        'Technology' as industry_sector,
        'Standard User' as user_role,
        'Business' as account_type,
        'English' as language_preference,
        current_date as effective_start_date,
        '9999-12-31'::date as effective_end_date,
        true as is_current_record,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
    
    union all
    
    select
        2 as user_dim_id,
        'USER002' as user_id,
        'Jane Smith' as user_name,
        'company.com' as email_domain,
        'Tech Solutions' as company,
        'Enterprise' as plan_type,
        'Paid' as plan_category,
        current_date as registration_date,
        'Active' as user_status,
        'North America' as geographic_region,
        'Technology' as industry_sector,
        'Standard User' as user_role,
        'Business' as account_type,
        'English' as language_preference,
        current_date as effective_start_date,
        '9999-12-31'::date as effective_end_date,
        true as is_current_record,
        current_date as load_date,
        current_date as update_date,
        'SAMPLE_DATA' as source_system
)

select * from sample_users
