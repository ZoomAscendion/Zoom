/*
  go_dim_user.sql
  Zoom Platform Analytics System - User Dimension
  
  Author: Data Engineering Team
  Description: User dimension with SCD Type 2 implementation for tracking historical changes
  
  This model creates a comprehensive user dimension with email domain extraction,
  plan categorization, and slowly changing dimension logic.
*/

{{ config(
    materialized='table',
    tags=['dimension', 'user', 'scd_type_2'],
    cluster_by=['plan_type', 'email_domain']
) }}

-- Source data with transformations
WITH source_users AS (
    SELECT 
        user_id,
        TRIM(COALESCE(user_name, 'Unknown User')) AS user_name,
        LOWER(TRIM(email)) AS email,
        TRIM(COALESCE(company, 'Unknown Company')) AS company,
        UPPER(TRIM(COALESCE(plan_type, 'UNKNOWN'))) AS plan_type,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
    FROM {{ source('silver', 'si_users') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
),

-- Extract email domains and derive additional attributes
user_attributes AS (
    SELECT 
        user_id,
        user_name,
        email,
        
        -- Extract email domain
        CASE 
            WHEN email IS NOT NULL AND email LIKE '%@%' 
            THEN UPPER(SUBSTRING(email, POSITION('@' IN email) + 1))
            ELSE 'UNKNOWN_DOMAIN'
        END AS email_domain,
        
        company,
        plan_type,
        
        -- Standardize plan categories
        CASE 
            WHEN plan_type IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN plan_type IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN plan_type IN ('BUSINESS') THEN 'Business'
            WHEN plan_type IN ('ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS plan_category,
        
        -- Derive registration date (using earliest load_date as proxy)
        MIN(load_date) OVER (PARTITION BY user_id) AS registration_date,
        
        -- Derive user status based on recent activity
        CASE 
            WHEN update_date >= CURRENT_DATE - 30 THEN 'Active'
            WHEN update_date >= CURRENT_DATE - 90 THEN 'Inactive'
            ELSE 'Dormant'
        END AS user_status,
        
        -- Geographic region (derived from email domain - simplified)
        CASE 
            WHEN email_domain LIKE '%.COM' THEN 'North America'
            WHEN email_domain LIKE '%.UK' OR email_domain LIKE '%.EU' THEN 'Europe'
            WHEN email_domain LIKE '%.JP' OR email_domain LIKE '%.CN' THEN 'Asia Pacific'
            ELSE 'Other'
        END AS geographic_region,
        
        -- Industry sector (simplified categorization based on company name)
        CASE 
            WHEN UPPER(company) LIKE '%TECH%' OR UPPER(company) LIKE '%SOFTWARE%' THEN 'Technology'
            WHEN UPPER(company) LIKE '%BANK%' OR UPPER(company) LIKE '%FINANCIAL%' THEN 'Financial Services'
            WHEN UPPER(company) LIKE '%HEALTH%' OR UPPER(company) LIKE '%MEDICAL%' THEN 'Healthcare'
            WHEN UPPER(company) LIKE '%EDU%' OR UPPER(company) LIKE '%UNIVERSITY%' THEN 'Education'
            ELSE 'Other'
        END AS industry_sector,
        
        -- User role (derived from plan type)
        CASE 
            WHEN plan_type IN ('ENTERPRISE', 'BUSINESS') THEN 'Business User'
            WHEN plan_type IN ('PRO', 'PROFESSIONAL') THEN 'Professional User'
            ELSE 'Individual User'
        END AS user_role,
        
        -- Account type
        CASE 
            WHEN plan_type = 'FREE' THEN 'Free'
            ELSE 'Paid'
        END AS account_type,
        
        -- Default values for additional attributes
        'UTC' AS time_zone,
        'English' AS language_preference,
        
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
        
    FROM source_users
),

-- Implement SCD Type 2 logic
scd_type_2 AS (
    SELECT 
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
        time_zone,
        language_preference,
        
        -- SCD Type 2 effective dates
        load_date AS effective_start_date,
        COALESCE(
            LEAD(load_date) OVER (
                PARTITION BY user_id 
                ORDER BY load_date
            ), 
            '9999-12-31'::DATE
        ) AS effective_end_date,
        
        -- Current record flag
        CASE 
            WHEN LEAD(load_date) OVER (
                PARTITION BY user_id 
                ORDER BY load_date
            ) IS NULL THEN TRUE
            ELSE FALSE
        END AS is_current_record,
        
        load_date,
        update_date,
        source_system
        
    FROM user_attributes
),

-- Final dimension with surrogate key
final_dimension AS (
    SELECT 
        -- Generate surrogate key
        ROW_NUMBER() OVER (ORDER BY user_id, effective_start_date) AS user_dim_id,
        
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
        time_zone,
        language_preference,
        effective_start_date,
        effective_end_date,
        is_current_record,
        load_date,
        update_date,
        source_system
        
    FROM scd_type_2
)

SELECT 
    user_dim_id,
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
    time_zone,
    language_preference,
    effective_start_date,
    effective_end_date,
    is_current_record,
    load_date,
    update_date,
    source_system
FROM final_dimension
ORDER BY user_dim_id