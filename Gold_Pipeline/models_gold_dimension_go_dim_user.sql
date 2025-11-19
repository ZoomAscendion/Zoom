{{ config(
    materialized='table',
    schema='gold',
    tags=['dimension', 'user', 'scd_type_2'],
    unique_key='user_dim_id'
) }}

-- User dimension table with SCD Type 2 implementation
-- Tracks historical changes in user attributes

WITH source_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        LOAD_DATE,
        UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM {{ source('silver', 'SI_USERS') }}
    WHERE VALIDATION_STATUS = 'VALID'
        AND DATA_QUALITY_SCORE >= 0.7
),

user_transformations AS (
    SELECT 
        -- Generate surrogate key for SCD Type 2
        {{ dbt_utils.generate_surrogate_key(['USER_ID', 'UPDATE_TIMESTAMP']) }} AS user_dim_id,
        
        -- Original user ID
        USER_ID,
        
        -- Standardized user name
        INITCAP(TRIM(USER_NAME)) AS user_name,
        
        -- Email domain extraction
        LOWER(TRIM(EMAIL)) AS email,
        SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) AS email_domain,
        
        -- Company standardization
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown'))) AS company,
        
        -- Plan type standardization
        UPPER(TRIM(PLAN_TYPE)) AS plan_type,
        
        -- Plan categorization
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS plan_category,
        
        -- Registration date (using load_date as proxy)
        LOAD_DATE AS registration_date,
        
        -- User status based on data quality and validation
        CASE 
            WHEN VALIDATION_STATUS = 'VALID' AND DATA_QUALITY_SCORE >= 0.9 THEN 'Active'
            WHEN VALIDATION_STATUS = 'VALID' AND DATA_QUALITY_SCORE >= 0.7 THEN 'Active - Quality Issues'
            ELSE 'Inactive'
        END AS user_status,
        
        -- Geographic region based on email domain
        CASE 
            WHEN SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) LIKE '%.com' THEN 'North America'
            WHEN SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) LIKE '%.uk' OR 
                 SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) LIKE '%.eu' OR
                 SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) LIKE '%.de' OR
                 SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) LIKE '%.fr' THEN 'Europe'
            WHEN SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) LIKE '%.jp' OR
                 SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) LIKE '%.cn' OR
                 SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) LIKE '%.in' THEN 'Asia Pacific'
            ELSE 'Other'
        END AS geographic_region,
        
        -- Industry sector (simplified categorization based on company name)
        CASE 
            WHEN UPPER(COMPANY) LIKE '%TECH%' OR UPPER(COMPANY) LIKE '%SOFTWARE%' THEN 'Technology'
            WHEN UPPER(COMPANY) LIKE '%HEALTH%' OR UPPER(COMPANY) LIKE '%MEDICAL%' THEN 'Healthcare'
            WHEN UPPER(COMPANY) LIKE '%FINANCE%' OR UPPER(COMPANY) LIKE '%BANK%' THEN 'Financial Services'
            WHEN UPPER(COMPANY) LIKE '%EDUCATION%' OR UPPER(COMPANY) LIKE '%SCHOOL%' OR UPPER(COMPANY) LIKE '%UNIVERSITY%' THEN 'Education'
            WHEN UPPER(COMPANY) LIKE '%RETAIL%' OR UPPER(COMPANY) LIKE '%STORE%' THEN 'Retail'
            ELSE 'Other'
        END AS industry_sector,
        
        -- User role (derived from plan type)
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('ENTERPRISE', 'BUSINESS') THEN 'Business User'
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('PRO', 'PROFESSIONAL') THEN 'Professional User'
            ELSE 'Individual User'
        END AS user_role,
        
        -- Account type
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) = 'FREE' THEN 'Free'
            ELSE 'Paid'
        END AS account_type,
        
        -- Language preference (default to English)
        'English' AS language_preference,
        
        -- SCD Type 2 fields
        COALESCE(LOAD_DATE, CURRENT_DATE()) AS effective_start_date,
        '9999-12-31'::DATE AS effective_end_date,
        TRUE AS is_current_record,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        SOURCE_SYSTEM AS source_system
        
    FROM source_users
)

SELECT 
    user_dim_id,
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