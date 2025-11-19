{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_dim_user', 'SI_USERS', 'go_dim_user', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_dim_user' AND process_status = 'STARTED'"
) }}

-- User dimension with enhanced attributes
WITH source_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_date,
        COALESCE(validation_status, 'UNKNOWN') AS validation_status,
        COALESCE(data_quality_score, 0) AS data_quality_score,
        source_system
    FROM {{ source('silver', 'si_users') }}
    WHERE user_id IS NOT NULL
),

transformed_users AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY user_id) AS user_dim_id,
        user_id,
        INITCAP(COALESCE(TRIM(user_name), 'Unknown User')) AS user_name,
        CASE 
            WHEN email IS NOT NULL AND POSITION('@' IN email) > 0 
            THEN UPPER(SUBSTRING(email, POSITION('@' IN email) + 1))
            ELSE 'UNKNOWN.COM'
        END AS email_domain,
        INITCAP(COALESCE(TRIM(company), 'Unknown Company')) AS company,
        CASE 
            WHEN UPPER(COALESCE(plan_type, '')) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(COALESCE(plan_type, '')) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(COALESCE(plan_type, '')) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS plan_type,
        CASE 
            WHEN UPPER(COALESCE(plan_type, '')) = 'FREE' THEN 'Free'
            WHEN UPPER(COALESCE(plan_type, '')) IN ('BASIC', 'PRO', 'PROFESSIONAL', 'BUSINESS', 'ENTERPRISE') THEN 'Paid'
            ELSE 'Unknown'
        END AS plan_category,
        COALESCE(load_date, CURRENT_DATE()) AS registration_date,
        CASE 
            WHEN validation_status = 'PASSED' AND data_quality_score >= 90 THEN 'Active'
            WHEN validation_status = 'PASSED' AND data_quality_score >= 70 THEN 'Active - Low Quality'
            ELSE 'Inactive'
        END AS user_status,
        'Unknown' AS geographic_region,
        'Other' AS industry_sector,
        'Standard User' AS user_role,
        CASE 
            WHEN UPPER(COALESCE(plan_type, '')) = 'FREE' THEN 'Individual'
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
