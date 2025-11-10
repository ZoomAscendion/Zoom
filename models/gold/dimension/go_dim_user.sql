{{ config(
    materialized='table',
    tags=['dimension'],
    cluster_by=['USER_NAME', 'PLAN_TYPE']
) }}

-- User dimension with SCD Type 2 implementation
-- Transforms Silver user data into business-ready dimensional format

WITH user_base AS (
    SELECT 
        u.user_id,
        u.user_name,
        u.email,
        u.company,
        u.plan_type,
        u.load_timestamp,
        u.update_timestamp,
        u.source_system,
        u.load_date,
        u.update_date
    FROM {{ source('silver', 'si_users') }} u
    WHERE u.validation_status = 'PASSED'
      AND u.data_quality_score >= 80
      AND u.user_id IS NOT NULL
      AND TRIM(u.user_name) != ''
),

user_enriched AS (
    SELECT 
        ub.*,
        
        -- Extract email domain for organizational analysis
        CASE 
            WHEN ub.email IS NOT NULL AND CONTAINS(ub.email, '@') THEN
                UPPER(SPLIT_PART(ub.email, '@', 2))
            ELSE 'UNKNOWN'
        END AS email_domain,
        
        -- Standardize plan types
        CASE 
            WHEN UPPER(ub.plan_type) IN ('BASIC', 'FREE', 'STARTER') THEN 'Basic'
            WHEN UPPER(ub.plan_type) IN ('PRO', 'PROFESSIONAL', 'PREMIUM') THEN 'Professional'
            WHEN UPPER(ub.plan_type) IN ('BUSINESS', 'TEAM', 'CORPORATE') THEN 'Business'
            WHEN UPPER(ub.plan_type) IN ('ENTERPRISE', 'UNLIMITED', 'ADVANCED') THEN 'Enterprise'
            ELSE 'Other'
        END AS plan_category,
        
        -- Derive geographic region from email domain patterns
        CASE 
            WHEN UPPER(ub.email) LIKE '%.COM' OR UPPER(ub.email) LIKE '%.US' THEN 'North America'
            WHEN UPPER(ub.email) LIKE '%.UK' OR UPPER(ub.email) LIKE '%.EU' OR UPPER(ub.email) LIKE '%.DE' 
                 OR UPPER(ub.email) LIKE '%.FR' OR UPPER(ub.email) LIKE '%.IT' THEN 'Europe'
            WHEN UPPER(ub.email) LIKE '%.JP' OR UPPER(ub.email) LIKE '%.CN' OR UPPER(ub.email) LIKE '%.IN' 
                 OR UPPER(ub.email) LIKE '%.SG' OR UPPER(ub.email) LIKE '%.AU' THEN 'Asia Pacific'
            WHEN UPPER(ub.email) LIKE '%.BR' OR UPPER(ub.email) LIKE '%.MX' OR UPPER(ub.email) LIKE '%.AR' THEN 'Latin America'
            ELSE 'Other'
        END AS geographic_region,
        
        -- Derive industry sector from company name patterns
        CASE 
            WHEN UPPER(ub.company) LIKE '%TECH%' OR UPPER(ub.company) LIKE '%SOFTWARE%' 
                 OR UPPER(ub.company) LIKE '%IT%' OR UPPER(ub.company) LIKE '%DIGITAL%' THEN 'Technology'
            WHEN UPPER(ub.company) LIKE '%BANK%' OR UPPER(ub.company) LIKE '%FINANCE%' 
                 OR UPPER(ub.company) LIKE '%INSURANCE%' THEN 'Financial Services'
            WHEN UPPER(ub.company) LIKE '%HEALTH%' OR UPPER(ub.company) LIKE '%MEDICAL%' 
                 OR UPPER(ub.company) LIKE '%HOSPITAL%' THEN 'Healthcare'
            WHEN UPPER(ub.company) LIKE '%SCHOOL%' OR UPPER(ub.company) LIKE '%UNIVERSITY%' 
                 OR UPPER(ub.company) LIKE '%EDUCATION%' THEN 'Education'
            WHEN UPPER(ub.company) LIKE '%RETAIL%' OR UPPER(ub.company) LIKE '%STORE%' 
                 OR UPPER(ub.company) LIKE '%SHOP%' THEN 'Retail'
            ELSE 'Other'
        END AS industry_sector
        
    FROM user_base ub
),

user_with_license_info AS (
    SELECT 
        ue.*,
        l.start_date AS registration_date,
        
        -- Derive user status from license information
        CASE 
            WHEN l.end_date IS NULL OR l.end_date >= CURRENT_DATE() THEN 'Active'
            WHEN l.end_date < CURRENT_DATE() THEN 'Inactive'
            ELSE 'Unknown'
        END AS user_status,
        
        -- User role based on plan type and usage patterns
        CASE 
            WHEN ue.plan_category = 'Enterprise' THEN 'Enterprise User'
            WHEN ue.plan_category = 'Business' THEN 'Business User'
            WHEN ue.plan_category = 'Professional' THEN 'Professional User'
            ELSE 'Basic User'
        END AS user_role,
        
        -- Account type classification
        CASE 
            WHEN ue.plan_category IN ('Enterprise', 'Business') THEN 'Corporate'
            WHEN ue.plan_category = 'Professional' THEN 'Professional'
            ELSE 'Individual'
        END AS account_type
        
    FROM user_enriched ue
    LEFT JOIN {{ source('silver', 'si_licenses') }} l 
        ON ue.user_id = l.assigned_to_user_id
        AND l.validation_status = 'PASSED'
        AND l.data_quality_score >= 80
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY user_id, load_timestamp) AS user_dim_id,
    user_name,
    email_domain,
    company,
    plan_type,
    plan_category,
    COALESCE(registration_date, load_date) AS registration_date,
    user_status,
    geographic_region,
    industry_sector,
    user_role,
    account_type,
    
    -- Default values for missing attributes
    'UTC' AS time_zone,
    'English' AS language_preference,
    
    -- SCD Type 2 implementation
    load_date AS effective_start_date,
    CAST('2099-12-31' AS DATE) AS effective_end_date,
    TRUE AS is_current_record,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    source_system
    
FROM user_with_license_info
WHERE user_name IS NOT NULL
  AND TRIM(user_name) != ''
ORDER BY user_dim_id
