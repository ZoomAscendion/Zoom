{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['dimension', 'user', 'scd_type2']
) }}

-- User dimension with SCD Type 2 implementation
-- Tracks historical changes in user attributes

WITH source_users AS (
    SELECT 
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
    FROM {{ source('silver_layer', 'si_users') }}
    WHERE validation_status = 'VALID'
      AND data_quality_score >= {{ var('data_quality_threshold') }}
),

user_transformations AS (
    SELECT 
        user_id,
        
        -- Standardized names
        INITCAP(TRIM(user_name)) AS user_name,
        LOWER(TRIM(email)) AS email,
        
        -- Email domain extraction
        UPPER(SPLIT_PART(LOWER(TRIM(email)), '@', 2)) AS email_domain,
        
        -- Company standardization
        INITCAP(TRIM(COALESCE(company, 'Unknown'))) AS company,
        
        -- Plan type standardization
        CASE 
            WHEN UPPER(TRIM(plan_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 'Basic'
            WHEN UPPER(TRIM(plan_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 'Pro'
            WHEN UPPER(TRIM(plan_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 'Enterprise'
            ELSE 'Basic'
        END AS plan_type,
        
        -- Plan category derivation
        CASE 
            WHEN UPPER(TRIM(plan_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 'Individual'
            WHEN UPPER(TRIM(plan_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 'Professional'
            WHEN UPPER(TRIM(plan_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 'Business'
            ELSE 'Individual'
        END AS plan_category,
        
        -- Registration date (using load_date as proxy)
        load_date AS registration_date,
        
        -- User status
        CASE 
            WHEN validation_status = 'VALID' THEN 'Active'
            ELSE 'Inactive'
        END AS user_status,
        
        -- Geographic region based on email domain
        CASE 
            WHEN email_domain LIKE '%.COM' OR email_domain LIKE '%.US' THEN 'North America'
            WHEN email_domain LIKE '%.UK' OR email_domain LIKE '%.EU' OR email_domain LIKE '%.DE' 
                 OR email_domain LIKE '%.FR' OR email_domain LIKE '%.IT' THEN 'Europe'
            WHEN email_domain LIKE '%.JP' OR email_domain LIKE '%.CN' OR email_domain LIKE '%.IN' 
                 OR email_domain LIKE '%.KR' THEN 'Asia Pacific'
            WHEN email_domain LIKE '%.AU' OR email_domain LIKE '%.NZ' THEN 'Oceania'
            WHEN email_domain LIKE '%.BR' OR email_domain LIKE '%.MX' OR email_domain LIKE '%.AR' THEN 'Latin America'
            ELSE 'Other'
        END AS geographic_region,
        
        -- Industry sector (simplified categorization)
        CASE 
            WHEN UPPER(company) LIKE '%TECH%' OR UPPER(company) LIKE '%SOFTWARE%' 
                 OR UPPER(company) LIKE '%IT%' THEN 'Technology'
            WHEN UPPER(company) LIKE '%FINANCE%' OR UPPER(company) LIKE '%BANK%' 
                 OR UPPER(company) LIKE '%INSURANCE%' THEN 'Financial Services'
            WHEN UPPER(company) LIKE '%HEALTH%' OR UPPER(company) LIKE '%MEDICAL%' 
                 OR UPPER(company) LIKE '%HOSPITAL%' THEN 'Healthcare'
            WHEN UPPER(company) LIKE '%EDU%' OR UPPER(company) LIKE '%SCHOOL%' 
                 OR UPPER(company) LIKE '%UNIVERSITY%' THEN 'Education'
            WHEN UPPER(company) LIKE '%RETAIL%' OR UPPER(company) LIKE '%STORE%' THEN 'Retail'
            ELSE 'Other'
        END AS industry_sector,
        
        -- User role (derived from plan type)
        CASE 
            WHEN UPPER(TRIM(plan_type)) IN ('ENTERPRISE', 'BUSINESS', 'CORPORATE') THEN 'Admin'
            WHEN UPPER(TRIM(plan_type)) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 'Power User'
            ELSE 'Standard User'
        END AS user_role,
        
        -- Account type
        CASE 
            WHEN UPPER(TRIM(plan_type)) IN ('BASIC', 'FREE', 'STARTER') THEN 'Individual'
            ELSE 'Business'
        END AS account_type,
        
        -- Language preference (default to English)
        'English' AS language_preference,
        
        -- SCD Type 2 fields
        load_timestamp AS effective_start_date,
        '9999-12-31'::TIMESTAMP AS effective_end_date,
        TRUE AS is_current_record,
        
        -- Audit fields
        load_date,
        update_date,
        source_system
        
    FROM source_users
)

SELECT 
    MD5(CONCAT(user_id, '_', effective_start_date::STRING)) AS user_dim_id,
    user_id,
    user_name,
    email_domain,
    company,
    plan_type,
    plan_category,
    registration_date,
    user_status,
    geographic_region,
    industry_sector,
    user_role,
    account_type,
    language_preference,
    effective_start_date,
    effective_end_date,
    is_current_record,
    load_date,
    update_date,
    source_system
FROM user_transformations
ORDER BY user_id, effective_start_date