{{ config(
    materialized='table',
    tags=['dimension'],
    cluster_by=['LICENSE_TYPE', 'LICENSE_CATEGORY']
) }}

-- License dimension with comprehensive license characteristics and pricing
-- Transforms Silver license data into business-ready dimensional format

WITH license_base AS (
    SELECT DISTINCT
        l.license_type
    FROM {{ source('silver', 'si_licenses') }} l
    WHERE l.validation_status = 'PASSED'
      AND l.data_quality_score >= 80
      AND l.license_type IS NOT NULL
      AND TRIM(l.license_type) != ''
),

license_enriched AS (
    SELECT 
        lb.license_type,
        
        -- License category standardization
        CASE 
            WHEN UPPER(lb.license_type) LIKE '%BASIC%' OR UPPER(lb.license_type) LIKE '%FREE%' THEN 'Basic'
            WHEN UPPER(lb.license_type) LIKE '%PRO%' OR UPPER(lb.license_type) LIKE '%PROFESSIONAL%' THEN 'Professional'
            WHEN UPPER(lb.license_type) LIKE '%BUSINESS%' OR UPPER(lb.license_type) LIKE '%TEAM%' THEN 'Business'
            WHEN UPPER(lb.license_type) LIKE '%ENTERPRISE%' OR UPPER(lb.license_type) LIKE '%UNLIMITED%' THEN 'Enterprise'
            ELSE 'Standard'
        END AS license_category,
        
        -- License tier classification
        CASE 
            WHEN UPPER(lb.license_type) LIKE '%BASIC%' OR UPPER(lb.license_type) LIKE '%FREE%' THEN 'Tier 1'
            WHEN UPPER(lb.license_type) LIKE '%PRO%' OR UPPER(lb.license_type) LIKE '%PROFESSIONAL%' THEN 'Tier 2'
            WHEN UPPER(lb.license_type) LIKE '%BUSINESS%' OR UPPER(lb.license_type) LIKE '%TEAM%' THEN 'Tier 3'
            WHEN UPPER(lb.license_type) LIKE '%ENTERPRISE%' OR UPPER(lb.license_type) LIKE '%UNLIMITED%' THEN 'Tier 4'
            ELSE 'Tier 2'
        END AS license_tier
        
    FROM license_base lb
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY license_type) AS license_id,
    license_type,
    license_category,
    license_tier,
    
    -- Participant limits based on license type
    CASE 
        WHEN license_category = 'Basic' THEN 100
        WHEN license_category = 'Professional' THEN 500
        WHEN license_category = 'Business' THEN 1000
        WHEN license_category = 'Enterprise' THEN 10000
        ELSE 500
    END AS max_participants,
    
    -- Storage limits in GB
    CASE 
        WHEN license_category = 'Basic' THEN 5
        WHEN license_category = 'Professional' THEN 50
        WHEN license_category = 'Business' THEN 200
        WHEN license_category = 'Enterprise' THEN 1000
        ELSE 50
    END AS storage_limit_gb,
    
    -- Recording limits in hours
    CASE 
        WHEN license_category = 'Basic' THEN 10
        WHEN license_category = 'Professional' THEN 100
        WHEN license_category = 'Business' THEN 500
        WHEN license_category = 'Enterprise' THEN 9999
        ELSE 100
    END AS recording_limit_hours,
    
    -- Feature flags
    CASE WHEN license_category IN ('Business', 'Enterprise') THEN TRUE ELSE FALSE END AS admin_features_included,
    CASE WHEN license_category IN ('Professional', 'Business', 'Enterprise') THEN TRUE ELSE FALSE END AS api_access_included,
    CASE WHEN license_category IN ('Business', 'Enterprise') THEN TRUE ELSE FALSE END AS sso_support_included,
    
    -- Pricing (monthly)
    CASE 
        WHEN license_category = 'Basic' THEN 0.00
        WHEN license_category = 'Professional' THEN 14.99
        WHEN license_category = 'Business' THEN 19.99
        WHEN license_category = 'Enterprise' THEN 39.99
        ELSE 14.99
    END AS monthly_price,
    
    -- Pricing (annual with discount)
    CASE 
        WHEN license_category = 'Basic' THEN 0.00
        WHEN license_category = 'Professional' THEN 149.90
        WHEN license_category = 'Business' THEN 199.90
        WHEN license_category = 'Enterprise' THEN 399.90
        ELSE 149.90
    END AS annual_price,
    
    -- License duration
    CASE 
        WHEN UPPER(license_type) LIKE '%MONTHLY%' THEN 1
        WHEN UPPER(license_type) LIKE '%ANNUAL%' OR UPPER(license_type) LIKE '%YEARLY%' THEN 12
        ELSE 12
    END AS license_duration_months,
    
    -- Concurrent meetings limit
    CASE 
        WHEN license_category = 'Basic' THEN 1
        WHEN license_category = 'Professional' THEN 5
        WHEN license_category = 'Business' THEN 20
        WHEN license_category = 'Enterprise' THEN 100
        ELSE 5
    END AS concurrent_meetings_limit,
    
    -- SCD Type 2 fields
    CAST('2020-01-01' AS DATE) AS effective_start_date,
    CAST('2099-12-31' AS DATE) AS effective_end_date,
    TRUE AS is_current_record,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_GOLD_PIPELINE' AS source_system
    
FROM license_enriched
ORDER BY license_id
