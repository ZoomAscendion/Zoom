{{ config(
    materialized='table'
) }}

-- Gold User Dimension Table
SELECT 
    ROW_NUMBER() OVER (ORDER BY user_id) as user_dimension_id,
    COALESCE(user_name, 'Unknown User') as user_name,
    COALESCE(email, 'unknown@example.com') as email_address,
    COALESCE(email_domain, 'unknown.com') as email_domain,
    COALESCE(company, 'Individual') as company,
    COALESCE(plan_type, 'Free') as plan_type,
    registration_date,
    COALESCE(account_age_days, 0) as account_age_days,
    COALESCE(user_segment, 'Standard') as user_segment,
    COALESCE(geographic_region, 'Unknown') as geographic_region,
    'Active' as user_status,
    -- SCD Type 2 columns
    COALESCE(registration_date, CURRENT_DATE()) as effective_start_date,
    '9999-12-31'::DATE as effective_end_date,
    TRUE as current_flag,
    -- Additional columns from Silver layer
    user_id,
    email,
    -- Metadata columns
    COALESCE(load_date, CURRENT_DATE()) as load_date,
    COALESCE(update_date, CURRENT_DATE()) as update_date,
    COALESCE(source_system, 'ZOOM_PLATFORM') as source_system
FROM {{ source('silver', 'si_users') }}
