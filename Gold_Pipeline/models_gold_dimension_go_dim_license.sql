/*
  go_dim_license.sql
  Zoom Platform Analytics System - License Dimension
  
  Author: Data Engineering Team
  Description: License dimension with SCD Type 2 for tracking license changes and entitlements
  
  This model creates a comprehensive license dimension with tier classification,
  entitlements mapping, and pricing information.
*/

{{ config(
    materialized='table',
    tags=['dimension', 'license', 'scd_type_2'],
    cluster_by=['license_category', 'license_tier']
) }}

-- Source license data with transformations
WITH source_licenses AS (
    SELECT 
        license_id,
        UPPER(TRIM(COALESCE(license_type, 'UNKNOWN'))) AS license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
    FROM {{ source('silver', 'si_licenses') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
),

-- License categorization and entitlements
license_attributes AS (
    SELECT 
        license_type,
        
        -- License category standardization
        CASE 
            WHEN license_type LIKE '%BASIC%' OR license_type LIKE '%FREE%' THEN 'Basic'
            WHEN license_type LIKE '%PRO%' OR license_type LIKE '%PROFESSIONAL%' THEN 'Professional'
            WHEN license_type LIKE '%BUSINESS%' THEN 'Business'
            WHEN license_type LIKE '%ENTERPRISE%' THEN 'Enterprise'
            ELSE 'Other'
        END AS license_category,
        
        -- License tier classification
        CASE 
            WHEN license_type LIKE '%BASIC%' OR license_type LIKE '%FREE%' THEN 'Tier 1'
            WHEN license_type LIKE '%PRO%' OR license_type LIKE '%PROFESSIONAL%' THEN 'Tier 2'
            WHEN license_type LIKE '%BUSINESS%' THEN 'Tier 3'
            WHEN license_type LIKE '%ENTERPRISE%' THEN 'Tier 4'
            ELSE 'Tier 0'
        END AS license_tier,
        
        -- Maximum participants based on license tier
        CASE 
            WHEN license_type LIKE '%BASIC%' OR license_type LIKE '%FREE%' THEN 100
            WHEN license_type LIKE '%PRO%' OR license_type LIKE '%PROFESSIONAL%' THEN 500
            WHEN license_type LIKE '%BUSINESS%' THEN 1000
            WHEN license_type LIKE '%ENTERPRISE%' THEN 5000
            ELSE 50
        END AS max_participants,
        
        -- Storage limit in GB
        CASE 
            WHEN license_type LIKE '%BASIC%' OR license_type LIKE '%FREE%' THEN 1
            WHEN license_type LIKE '%PRO%' OR license_type LIKE '%PROFESSIONAL%' THEN 10
            WHEN license_type LIKE '%BUSINESS%' THEN 100
            WHEN license_type LIKE '%ENTERPRISE%' THEN 1000
            ELSE 1
        END AS storage_limit_gb,
        
        -- Recording limit in hours
        CASE 
            WHEN license_type LIKE '%BASIC%' OR license_type LIKE '%FREE%' THEN 0
            WHEN license_type LIKE '%PRO%' OR license_type LIKE '%PROFESSIONAL%' THEN 10
            WHEN license_type LIKE '%BUSINESS%' THEN 100
            WHEN license_type LIKE '%ENTERPRISE%' THEN 1000
            ELSE 0
        END AS recording_limit_hours,
        
        -- Admin features included
        CASE 
            WHEN license_type LIKE '%BUSINESS%' OR license_type LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS admin_features_included,
        
        -- API access included
        CASE 
            WHEN license_type LIKE '%ENTERPRISE%' THEN TRUE
            WHEN license_type LIKE '%BUSINESS%' AND license_type LIKE '%API%' THEN TRUE
            ELSE FALSE
        END AS api_access_included,
        
        -- SSO support included
        CASE 
            WHEN license_type LIKE '%ENTERPRISE%' THEN TRUE
            WHEN license_type LIKE '%BUSINESS%' AND license_type LIKE '%SSO%' THEN TRUE
            ELSE FALSE
        END AS sso_support_included,
        
        -- Monthly pricing (estimated based on tier)
        CASE 
            WHEN license_type LIKE '%BASIC%' OR license_type LIKE '%FREE%' THEN 0.00
            WHEN license_type LIKE '%PRO%' OR license_type LIKE '%PROFESSIONAL%' THEN 14.99
            WHEN license_type LIKE '%BUSINESS%' THEN 19.99
            WHEN license_type LIKE '%ENTERPRISE%' THEN 39.99
            ELSE 0.00
        END AS monthly_price,
        
        -- Annual pricing (with discount)
        CASE 
            WHEN license_type LIKE '%BASIC%' OR license_type LIKE '%FREE%' THEN 0.00
            WHEN license_type LIKE '%PRO%' OR license_type LIKE '%PROFESSIONAL%' THEN 149.90
            WHEN license_type LIKE '%BUSINESS%' THEN 199.90
            WHEN license_type LIKE '%ENTERPRISE%' THEN 399.90
            ELSE 0.00
        END AS annual_price,
        
        -- License duration in months
        CASE 
            WHEN license_type LIKE '%MONTHLY%' THEN 1
            WHEN license_type LIKE '%ANNUAL%' OR license_type LIKE '%YEARLY%' THEN 12
            WHEN license_type LIKE '%TRIAL%' THEN 1
            ELSE 12
        END AS license_duration_months,
        
        -- Concurrent meetings limit
        CASE 
            WHEN license_type LIKE '%BASIC%' OR license_type LIKE '%FREE%' THEN 1
            WHEN license_type LIKE '%PRO%' OR license_type LIKE '%PROFESSIONAL%' THEN 2
            WHEN license_type LIKE '%BUSINESS%' THEN 10
            WHEN license_type LIKE '%ENTERPRISE%' THEN 100
            ELSE 1
        END AS concurrent_meetings_limit,
        
        start_date,
        end_date,
        load_date,
        update_date,
        source_system
        
    FROM source_licenses
),

-- Get unique license types with their attributes
unique_licenses AS (
    SELECT DISTINCT
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
        MIN(start_date) AS earliest_start_date,
        MAX(end_date) AS latest_end_date,
        MIN(load_date) AS load_date,
        MAX(update_date) AS update_date,
        source_system
    FROM license_attributes
    GROUP BY 
        license_type, license_category, license_tier, max_participants,
        storage_limit_gb, recording_limit_hours, admin_features_included,
        api_access_included, sso_support_included, monthly_price,
        annual_price, license_duration_months, concurrent_meetings_limit,
        source_system
),

-- Implement SCD Type 2 logic for license changes
scd_type_2 AS (
    SELECT 
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
        load_date AS effective_start_date,
        COALESCE(
            LEAD(load_date) OVER (
                PARTITION BY license_type 
                ORDER BY load_date
            ), 
            '9999-12-31'::DATE
        ) AS effective_end_date,
        
        -- Current record flag
        CASE 
            WHEN LEAD(load_date) OVER (
                PARTITION BY license_type 
                ORDER BY load_date
            ) IS NULL THEN TRUE
            ELSE FALSE
        END AS is_current_record,
        
        load_date,
        update_date,
        source_system
        
    FROM unique_licenses
),

-- Final dimension with surrogate key
final_dimension AS (
    SELECT 
        -- Generate surrogate key
        ROW_NUMBER() OVER (ORDER BY license_type, effective_start_date) AS license_id,
        
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
        load_date,
        update_date,
        source_system
        
    FROM scd_type_2
)

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
    effective_start_date,
    effective_end_date,
    is_current_record,
    load_date,
    update_date,
    source_system
FROM final_dimension
ORDER BY license_id