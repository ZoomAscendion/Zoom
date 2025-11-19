{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_DIM_USER', run_started_at]) }}', 'GO_DIM_USER_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_USERS', 'GO_DIM_USER', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_DIM_USER', run_started_at]) }}'"
) }}

-- User dimension transformation from Silver layer
WITH user_source AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        validation_status,
        source_system
    FROM {{ source('silver', 'si_users') }}
    WHERE validation_status = 'PASSED'
),

user_transformed AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} AS user_key,
        user_id,
        INITCAP(TRIM(user_name)) AS user_name,
        UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) AS email_domain,
        INITCAP(TRIM(company)) AS company,
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
        DATE(load_timestamp) AS registration_date,
        CASE 
            WHEN validation_status = 'PASSED' THEN 'Active'
            ELSE 'Inactive'
        END AS user_status,
        CASE 
            WHEN UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) LIKE '%.COM' THEN 'North America'
            WHEN UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) LIKE '%.UK' OR UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) LIKE '%.EU' THEN 'Europe'
            ELSE 'Unknown'
        END AS geographic_region,
        CASE 
            WHEN UPPER(company) LIKE '%TECH%' OR UPPER(company) LIKE '%SOFTWARE%' THEN 'Technology'
            WHEN UPPER(company) LIKE '%BANK%' OR UPPER(company) LIKE '%FINANCE%' THEN 'Financial Services'
            ELSE 'Unknown'
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
    FROM user_source
)

SELECT * FROM user_transformed
