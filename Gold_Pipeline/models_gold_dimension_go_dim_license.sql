{{ config(
    materialized='table',
    schema='gold',
    tags=['dimension', 'license'],
    unique_key='license_id'
) }}

-- License dimension table for Gold layer
-- Contains comprehensive license information and pricing details

WITH source_licenses AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        LOAD_DATE,
        UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM {{ source('silver', 'SI_LICENSES') }}
    WHERE VALIDATION_STATUS = 'VALID'
        AND DATA_QUALITY_SCORE >= 0.7
),

license_transformations AS (
    SELECT 
        -- Original license ID
        LICENSE_ID,
        
        -- Standardized license type
        UPPER(TRIM(LICENSE_TYPE)) AS license_type,
        
        -- License categorization
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('BUSINESS') THEN 'Business'
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ENTERPRISE', 'ENTERPRISE_PLUS') THEN 'Enterprise'
            ELSE 'Other'
        END AS license_category,
        
        -- License tier
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'FREE' THEN 'Tier 0'
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('BASIC', 'PRO') THEN 'Tier 1'
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BUSINESS' THEN 'Tier 2'
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ENTERPRISE', 'ENTERPRISE_PLUS') THEN 'Tier 3'
            ELSE 'Tier 1'
        END AS license_tier,
        
        -- Maximum participants based on license type
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'FREE' THEN 100
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BASIC' THEN 100
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'PRO' THEN 100
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BUSINESS' THEN 300
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ENTERPRISE', 'ENTERPRISE_PLUS') THEN 500
            ELSE 100
        END AS max_participants,
        
        -- Storage limit in GB
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'FREE' THEN 0
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BASIC' THEN 0
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'PRO' THEN 1
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BUSINESS' THEN 5
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ENTERPRISE', 'ENTERPRISE_PLUS') THEN 100
            ELSE 0
        END AS storage_limit_gb,
        
        -- Recording limit in hours
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'FREE' THEN 0
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BASIC' THEN 0
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'PRO' THEN 1
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BUSINESS' THEN 5
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ENTERPRISE', 'ENTERPRISE_PLUS') THEN 100
            ELSE 0
        END AS recording_limit_hours,
        
        -- Admin features included
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('BUSINESS', 'ENTERPRISE', 'ENTERPRISE_PLUS') THEN TRUE
            ELSE FALSE
        END AS admin_features_included,
        
        -- API access included
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('PRO', 'BUSINESS', 'ENTERPRISE', 'ENTERPRISE_PLUS') THEN TRUE
            ELSE FALSE
        END AS api_access_included,
        
        -- SSO support included
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('BUSINESS', 'ENTERPRISE', 'ENTERPRISE_PLUS') THEN TRUE
            ELSE FALSE
        END AS sso_support_included,
        
        -- Monthly price (USD)
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'FREE' THEN 0.00
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BASIC' THEN 0.00
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'PRO' THEN 14.99
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BUSINESS' THEN 19.99
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'ENTERPRISE' THEN 240.00
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'ENTERPRISE_PLUS' THEN 400.00
            ELSE 0.00
        END AS monthly_price,
        
        -- Annual price (USD)
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'FREE' THEN 0.00
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BASIC' THEN 0.00
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'PRO' THEN 149.90
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BUSINESS' THEN 199.90
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'ENTERPRISE' THEN 2400.00
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'ENTERPRISE_PLUS' THEN 4000.00
            ELSE 0.00
        END AS annual_price,
        
        -- License benefits description
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'FREE' THEN 'Basic video conferencing, 40-minute limit on group meetings'
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BASIC' THEN 'Basic video conferencing with extended meeting duration'
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'PRO' THEN 'Small team collaboration, cloud recording, admin features'
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'BUSINESS' THEN 'Small/medium business, company branding, admin dashboard'
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'ENTERPRISE' THEN 'Large enterprise, advanced security, unlimited cloud storage'
            WHEN UPPER(TRIM(LICENSE_TYPE)) = 'ENTERPRISE_PLUS' THEN 'Enterprise plus advanced compliance and analytics'
            ELSE 'Standard Zoom license benefits'
        END AS license_benefits,
        
        -- Effective dates
        START_DATE AS effective_start_date,
        COALESCE(END_DATE, '9999-12-31'::DATE) AS effective_end_date,
        
        -- Current record indicator
        CASE 
            WHEN END_DATE IS NULL OR END_DATE > CURRENT_DATE() THEN TRUE
            ELSE FALSE
        END AS is_current_record,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        SOURCE_SYSTEM AS source_system
        
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
FROM license_transformations
ORDER BY license_type, effective_start_date