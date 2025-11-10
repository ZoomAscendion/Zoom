{{ config(
    materialized='table',
    cluster_by=['LICENSE_CATEGORY', 'LOAD_DATE'],
    tags=['dimension', 'license', 'scd2']
) }}

-- License dimension with SCD Type 2 for tracking license changes over time
-- Contains license types, entitlements, and pricing information

WITH source_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        validation_status,
        data_quality_score
    FROM {{ source('silver', 'si_licenses') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
),

license_transformations AS (
    SELECT 
        license_id,
        UPPER(TRIM(COALESCE(license_type, 'UNKNOWN'))) AS license_type,
        
        -- License category standardization
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BASIC%' THEN 'Basic'
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%PRO%' THEN 'Professional'
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BUSINESS%' THEN 'Business'
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%ENTERPRISE%' THEN 'Enterprise'
            ELSE 'Other'
        END AS license_category,
        
        -- License tier mapping
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BASIC%' THEN 'Tier 1'
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%PRO%' THEN 'Tier 2'
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BUSINESS%' THEN 'Tier 3'
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%ENTERPRISE%' THEN 'Tier 4'
            ELSE 'Tier 0'
        END AS license_tier,
        
        -- License entitlements based on tier
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BASIC%' THEN 100
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%PRO%' THEN 500
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BUSINESS%' THEN 1000
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%ENTERPRISE%' THEN 5000
            ELSE 50
        END AS max_participants,
        
        -- Storage limits
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BASIC%' THEN 5
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%PRO%' THEN 100
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BUSINESS%' THEN 1000
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%ENTERPRISE%' THEN 10000
            ELSE 1
        END AS storage_limit_gb,
        
        -- Recording limits
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BASIC%' THEN 10
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%PRO%' THEN 100
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BUSINESS%' THEN 1000
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%ENTERPRISE%' THEN 10000
            ELSE 5
        END AS recording_limit_hours,
        
        -- Feature flags
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) IN ('BUSINESS', 'ENTERPRISE') THEN TRUE
            ELSE FALSE
        END AS admin_features_included,
        
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) = 'ENTERPRISE' THEN TRUE
            ELSE FALSE
        END AS api_access_included,
        
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) IN ('BUSINESS', 'ENTERPRISE') THEN TRUE
            ELSE FALSE
        END AS sso_support_included,
        
        -- Pricing (estimated)
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BASIC%' THEN 14.99
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%PRO%' THEN 19.99
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BUSINESS%' THEN 39.99
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%ENTERPRISE%' THEN 79.99
            ELSE 0.00
        END AS monthly_price,
        
        -- Annual pricing (10% discount)
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BASIC%' THEN 161.89
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%PRO%' THEN 215.89
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BUSINESS%' THEN 431.89
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%ENTERPRISE%' THEN 863.89
            ELSE 0.00
        END AS annual_price,
        
        -- License duration
        CASE 
            WHEN license_type LIKE '%ANNUAL%' THEN 12
            WHEN license_type LIKE '%MONTHLY%' THEN 1
            ELSE 12
        END AS license_duration_months,
        
        -- Concurrent meetings limit
        CASE 
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BASIC%' THEN 1
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%PRO%' THEN 5
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%BUSINESS%' THEN 25
            WHEN UPPER(TRIM(COALESCE(license_type, ''))) LIKE '%ENTERPRISE%' THEN 100
            ELSE 1
        END AS concurrent_meetings_limit,
        
        start_date,
        end_date,
        load_date,
        update_timestamp,
        source_system
        
    FROM source_licenses
),

-- SCD Type 2 implementation
scd_type2_logic AS (
    SELECT 
        license_id,
        license_type,
        license_category,
        license_tier,
        max_participants,
        storage_limit_gb,
        recording_limit_hours,
        admin_features_included,
        api_access_included,
        sso_support_included,
        monthly_price,
        annual_price,
        license_duration_months,
        concurrent_meetings_limit,
        
        -- SCD Type 2 effective dates
        start_date AS effective_start_date,
        
        -- Calculate effective end date
        COALESCE(
            LEAD(start_date, 1) OVER (
                PARTITION BY license_id 
                ORDER BY start_date
            ) - 1,
            COALESCE(end_date, '9999-12-31'::DATE)
        ) AS effective_end_date,
        
        -- Current record indicator
        CASE 
            WHEN end_date IS NULL OR end_date >= CURRENT_DATE() THEN TRUE 
            ELSE FALSE 
        END AS is_current_record,
        
        load_date,
        update_timestamp,
        source_system
        
    FROM license_transformations
),

final_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY license_id, effective_start_date) AS license_dim_id,
        license_id,
        license_type,
        license_category,
        license_tier,
        max_participants,
        storage_limit_gb,
        recording_limit_hours,
        admin_features_included,
        api_access_included,
        sso_support_included,
        monthly_price,
        annual_price,
        license_duration_months,
        concurrent_meetings_limit,
        effective_start_date,
        effective_end_date,
        is_current_record,
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
        
    FROM scd_type2_logic
)

SELECT * FROM final_dimension
ORDER BY license_id, effective_start_date
