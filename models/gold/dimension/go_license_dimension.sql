{{ config(
    materialized='table'
) }}

-- Gold License Dimension Table
WITH license_data AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        license_status,
        license_duration_days,
        renewal_flag,
        load_date,
        update_date,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY COALESCE(update_date, load_date, CURRENT_DATE()) DESC) as rn
    FROM {{ source('silver', 'si_licenses') }}
),

latest_license_data AS (
    SELECT *
    FROM license_data
    WHERE rn = 1
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY license_id) as license_dimension_id,
    COALESCE(license_type, 'Basic') as license_type,
    CASE 
        WHEN license_type = 'Basic' THEN 'Basic plan with essential meeting features'
        WHEN license_type = 'Pro' THEN 'Professional plan with advanced features'
        WHEN license_type = 'Business' THEN 'Business plan with admin and reporting features'
        WHEN license_type = 'Enterprise' THEN 'Enterprise plan with full feature set'
        ELSE CONCAT('License type: ', COALESCE(license_type, 'Unknown'))
    END as license_description,
    CASE 
        WHEN license_type IN ('Basic', 'Free') THEN 'Basic'
        WHEN license_type = 'Pro' THEN 'Professional'
        WHEN license_type = 'Business' THEN 'Business'
        WHEN license_type = 'Enterprise' THEN 'Enterprise'
        ELSE 'Standard'
    END as license_category,
    CASE 
        WHEN license_type = 'Basic' THEN 'Tier 1'
        WHEN license_type = 'Pro' THEN 'Tier 2'
        WHEN license_type = 'Business' THEN 'Tier 3'
        WHEN license_type = 'Enterprise' THEN 'Tier 4'
        ELSE 'Tier 1'
    END as price_tier,
    CASE 
        WHEN license_type = 'Basic' THEN 100
        WHEN license_type = 'Pro' THEN 500
        WHEN license_type = 'Business' THEN 1000
        WHEN license_type = 'Enterprise' THEN 5000
        ELSE 100
    END as max_participants,
    CASE 
        WHEN license_type = 'Basic' THEN 40
        WHEN license_type IN ('Pro', 'Business', 'Enterprise') THEN 1440
        ELSE 40
    END as meeting_duration_limit,
    CASE 
        WHEN license_type = 'Basic' THEN 1
        WHEN license_type = 'Pro' THEN 5
        WHEN license_type = 'Business' THEN 10
        WHEN license_type = 'Enterprise' THEN 100
        ELSE 1
    END as storage_limit_gb,
    CASE 
        WHEN license_type IN ('Business', 'Enterprise') THEN 'Premium'
        WHEN license_type = 'Pro' THEN 'Standard'
        ELSE 'Basic'
    END as support_level,
    -- SCD Type 2 columns
    COALESCE(start_date, CURRENT_DATE()) as effective_start_date,
    COALESCE(end_date, '9999-12-31'::DATE) as effective_end_date,
    CASE WHEN end_date IS NULL OR end_date > CURRENT_DATE() THEN TRUE ELSE FALSE END as current_flag,
    -- Additional columns from Silver layer
    license_id,
    assigned_to_user_id,
    start_date,
    end_date,
    COALESCE(license_status, 'Active') as license_status,
    COALESCE(license_duration_days, 365) as license_duration_days,
    COALESCE(renewal_flag, FALSE) as renewal_flag,
    -- Metadata columns
    COALESCE(load_date, CURRENT_DATE()) as load_date,
    COALESCE(update_date, CURRENT_DATE()) as update_date,
    COALESCE(source_system, 'ZOOM_LICENSING') as source_system
FROM latest_license_data
