{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['dimension', 'license', 'scd_type2']
) }}

-- License dimension with SCD Type 2 implementation
-- Contains comprehensive license metadata and pricing information

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
        update_date,
        data_quality_score,
        validation_status
    FROM {{ source('silver_layer', 'si_licenses') }}
    WHERE validation_status = 'VALID'
      AND data_quality_score >= {{ var('data_quality_threshold') }}
),

license_enrichment AS (
    SELECT 
        license_id,
        
        -- Standardized license type
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 'Basic'
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 'Pro'
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 'Enterprise'
            ELSE 'Basic'
        END AS license_type,
        
        -- License category
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 'Individual'
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 'Professional'
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 'Enterprise'
            ELSE 'Individual'
        END AS license_category,
        
        -- License tier
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 'Tier 1'
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 'Tier 2'
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 'Tier 3'
            ELSE 'Tier 1'
        END AS license_tier,
        
        -- Maximum participants based on license type
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 100
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 500
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 1000
            ELSE 100
        END AS max_participants,
        
        -- Storage limit in GB
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 5
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 100
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 1000
            ELSE 5
        END AS storage_limit_gb,
        
        -- Recording limit in hours
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 0
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 100
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 1000
            ELSE 0
        END AS recording_limit_hours,
        
        -- Admin features included
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN TRUE
            ELSE FALSE
        END AS admin_features_included,
        
        -- API access included
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM', 'ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN TRUE
            ELSE FALSE
        END AS api_access_included,
        
        -- SSO support included
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN TRUE
            ELSE FALSE
        END AS sso_support_included,
        
        -- Monthly pricing
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 0.00
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 14.99
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 19.99
            ELSE 0.00
        END AS monthly_price,
        
        -- Annual pricing (with discount)
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 0.00
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 149.90
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 199.90
            ELSE 0.00
        END AS annual_price,
        
        -- License benefits
        CASE 
            WHEN UPPER(TRIM(license_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 'Basic video conferencing, 40-minute limit'
            WHEN UPPER(TRIM(license_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 'Unlimited meeting duration, cloud recording, admin features'
            WHEN UPPER(TRIM(license_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 'Advanced admin controls, SSO, unlimited cloud storage, dedicated customer success manager'
            ELSE 'Basic video conferencing'
        END AS license_benefits,
        
        -- SCD Type 2 fields
        start_date AS effective_start_date,
        COALESCE(end_date, '9999-12-31'::DATE) AS effective_end_date,
        CASE WHEN end_date IS NULL OR end_date > CURRENT_DATE() THEN TRUE ELSE FALSE END AS is_current_record,
        
        -- Audit fields
        assigned_to_user_id,
        load_date,
        update_date,
        source_system
        
    FROM source_licenses
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
    license_benefits,
    effective_start_date,
    effective_end_date,
    is_current_record,
    load_date,
    update_date,
    source_system
FROM license_enrichment
ORDER BY license_id, effective_start_date