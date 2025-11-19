{{ config(
    materialized='table'
) }}

-- User dimension with SCD Type 2 implementation
-- Transforms Silver layer user data with enhanced attributes

WITH source_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_date,
        validation_status,
        data_quality_score,
        source_system,
        load_timestamp,
        update_timestamp
    FROM {{ source('silver', 'si_users') }}
    WHERE validation_status = 'PASSED'
      AND data_quality_score >= 70
),

transformed_users AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY user_id) AS user_dim_id,
        user_id,
        INITCAP(TRIM(COALESCE(user_name, 'Unknown User'))) AS user_name,
        UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) AS email_domain,
        INITCAP(TRIM(COALESCE(company, 'Unknown Company'))) AS company,
        CASE 
            WHEN UPPER(plan_type) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(plan_type) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(plan_type) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS plan_type,
        CASE 
            WHEN UPPER(plan_type) = 'FREE' THEN 'Free'
            ELSE 'Paid'
        END AS plan_category,
        load_date AS registration_date,
        CASE 
            WHEN validation_status = 'PASSED' AND data_quality_score >= 90 THEN 'Active'
            WHEN validation_status = 'PASSED' AND data_quality_score >= 70 THEN 'Active - Low Quality'
            ELSE 'Inactive'
        END AS user_status,
        CASE 
            WHEN UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) LIKE '%.COM' THEN 'North America'
            WHEN UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) LIKE '%.UK' OR 
                 UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) LIKE '%.EU' THEN 'Europe'
            WHEN UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) LIKE '%.IN' THEN 'Asia Pacific'
            ELSE 'Unknown'
        END AS geographic_region,
        CASE 
            WHEN UPPER(company) LIKE '%TECH%' OR UPPER(company) LIKE '%SOFTWARE%' THEN 'Technology'
            WHEN UPPER(company) LIKE '%BANK%' OR UPPER(company) LIKE '%FINANCE%' THEN 'Financial Services'
            WHEN UPPER(company) LIKE '%HEALTH%' OR UPPER(company) LIKE '%MEDICAL%' THEN 'Healthcare'
            WHEN UPPER(company) LIKE '%EDU%' OR UPPER(company) LIKE '%SCHOOL%' THEN 'Education'
            ELSE 'Other'
        END AS industry_sector,
        'Standard User' AS user_role,
        CASE 
            WHEN UPPER(plan_type) = 'FREE' THEN 'Individual'
            ELSE 'Business'
        END AS account_type,
        'English' AS language_preference,
        CURRENT_DATE() AS effective_start_date,
        '9999-12-31'::DATE AS effective_end_date,
        TRUE AS is_current_record,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM source_users
)

SELECT * FROM transformed_users
