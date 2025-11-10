{{ config(
    materialized='table',
    cluster_by=['PLAN_TYPE', 'LOAD_DATE'],
    tags=['dimension', 'user', 'scd2']
) }}

-- User dimension with SCD Type 2 implementation
-- Tracks historical changes in user attributes over time

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
        validation_status,
        data_quality_score
    FROM {{ source('silver', 'si_users') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
),

user_transformations AS (
    SELECT 
        user_id,
        
        -- Cleansed and standardized user name
        COALESCE(TRIM(INITCAP(user_name)), 'Unknown User') AS user_name,
        
        -- Email domain extraction
        CASE 
            WHEN email IS NOT NULL AND email LIKE '%@%' THEN 
                LOWER(TRIM(SUBSTRING(email, POSITION('@' IN email) + 1)))
            ELSE 'unknown-domain.com'
        END AS email_domain,
        
        -- Cleansed company name
        COALESCE(TRIM(INITCAP(company)), 'Unknown Company') AS company,
        
        -- Standardized plan type
        UPPER(TRIM(COALESCE(plan_type, 'UNKNOWN'))) AS plan_type,
        
        -- Plan category derivation
        CASE 
            WHEN UPPER(TRIM(COALESCE(plan_type, ''))) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(TRIM(COALESCE(plan_type, ''))) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(TRIM(COALESCE(plan_type, ''))) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS plan_category,
        
        -- Registration date (using load_date as proxy)
        load_date AS registration_date,
        
        -- User status derivation
        CASE 
            WHEN update_timestamp >= CURRENT_DATE() - 30 THEN 'Active'
            WHEN update_timestamp >= CURRENT_DATE() - 90 THEN 'Inactive'
            ELSE 'Dormant'
        END AS user_status,
        
        -- Geographic region (derived from email domain - simplified)
        CASE 
            WHEN LOWER(email) LIKE '%.com' OR LOWER(email) LIKE '%.us' THEN 'North America'
            WHEN LOWER(email) LIKE '%.uk' OR LOWER(email) LIKE '%.eu' THEN 'Europe'
            WHEN LOWER(email) LIKE '%.jp' OR LOWER(email) LIKE '%.cn' OR LOWER(email) LIKE '%.in' THEN 'Asia Pacific'
            ELSE 'Other'
        END AS geographic_region,
        
        -- Industry sector (derived from company name - simplified)
        CASE 
            WHEN LOWER(COALESCE(company, '')) LIKE '%tech%' OR LOWER(COALESCE(company, '')) LIKE '%software%' THEN 'Technology'
            WHEN LOWER(COALESCE(company, '')) LIKE '%finance%' OR LOWER(COALESCE(company, '')) LIKE '%bank%' THEN 'Financial Services'
            WHEN LOWER(COALESCE(company, '')) LIKE '%health%' OR LOWER(COALESCE(company, '')) LIKE '%medical%' THEN 'Healthcare'
            WHEN LOWER(COALESCE(company, '')) LIKE '%edu%' OR LOWER(COALESCE(company, '')) LIKE '%school%' THEN 'Education'
            ELSE 'Other'
        END AS industry_sector,
        
        -- User role (simplified derivation)
        CASE 
            WHEN UPPER(COALESCE(plan_type, '')) = 'ENTERPRISE' THEN 'Admin'
            WHEN UPPER(COALESCE(plan_type, '')) IN ('BUSINESS', 'PRO') THEN 'Manager'
            ELSE 'User'
        END AS user_role,
        
        -- Account type
        CASE 
            WHEN UPPER(COALESCE(plan_type, '')) IN ('ENTERPRISE', 'BUSINESS') THEN 'Business'
            ELSE 'Individual'
        END AS account_type,
        
        -- Time zone (simplified - based on geographic region)
        CASE 
            WHEN LOWER(email) LIKE '%.com' OR LOWER(email) LIKE '%.us' THEN 'America/New_York'
            WHEN LOWER(email) LIKE '%.uk' OR LOWER(email) LIKE '%.eu' THEN 'Europe/London'
            WHEN LOWER(email) LIKE '%.jp' THEN 'Asia/Tokyo'
            WHEN LOWER(email) LIKE '%.in' THEN 'Asia/Kolkata'
            ELSE 'UTC'
        END AS time_zone,
        
        -- Language preference (simplified)
        CASE 
            WHEN LOWER(email) LIKE '%.jp' THEN 'Japanese'
            WHEN LOWER(email) LIKE '%.cn' THEN 'Chinese'
            WHEN LOWER(email) LIKE '%.fr' THEN 'French'
            WHEN LOWER(email) LIKE '%.de' THEN 'German'
            ELSE 'English'
        END AS language_preference,
        
        load_date,
        update_timestamp,
        source_system
        
    FROM source_users
),

-- SCD Type 2 implementation
scd_type2_logic AS (
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
        
        -- Calculate effective end date using LEAD function
        COALESCE(
            LEAD(load_date, 1) OVER (
                PARTITION BY user_id 
                ORDER BY load_date
            ) - 1,
            '9999-12-31'::DATE
        ) AS effective_end_date,
        
        -- Current record indicator
        CASE 
            WHEN LEAD(load_date, 1) OVER (
                PARTITION BY user_id 
                ORDER BY load_date
            ) IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_current_record,
        
        load_date,
        update_timestamp,
        source_system
        
    FROM user_transformations
),

final_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY user_id, effective_start_date) AS user_dim_id,
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
ORDER BY user_id, effective_start_date
