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
    FROM {{ source('gold', 'si_users') }}
    WHERE validation_status = 'PASSED'
),

user_transformed AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY user_id) AS user_dim_id,
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} AS user_key,
        user_id,
        INITCAP(TRIM(COALESCE(user_name, 'Unknown'))) AS user_name,
        CASE 
            WHEN email IS NOT NULL AND POSITION('@' IN email) > 0 
            THEN UPPER(SUBSTRING(email, POSITION('@' IN email) + 1))
            ELSE 'UNKNOWN.COM'
        END AS email_domain,
        INITCAP(TRIM(COALESCE(company, 'Unknown Company'))) AS company,
        CASE 
            WHEN UPPER(COALESCE(plan_type, 'FREE')) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(COALESCE(plan_type, 'FREE')) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(COALESCE(plan_type, 'FREE')) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS plan_type,
        CASE 
            WHEN UPPER(COALESCE(plan_type, 'FREE')) = 'FREE' THEN 'Free'
            ELSE 'Paid'
        END AS plan_category,
        COALESCE(DATE(load_timestamp), CURRENT_DATE()) AS registration_date,
        CASE 
            WHEN validation_status = 'PASSED' THEN 'Active'
            ELSE 'Inactive'
        END AS user_status,
        'Unknown' AS geographic_region,
        'Unknown' AS industry_sector,
        'Standard User' AS user_role,
        CASE 
            WHEN UPPER(COALESCE(plan_type, 'FREE')) = 'FREE' THEN 'Individual'
            ELSE 'Business'
        END AS account_type,
        'English' AS language_preference,
        CURRENT_DATE() AS effective_start_date,
        '9999-12-31'::DATE AS effective_end_date,
        TRUE AS is_current_record,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM user_source
)

SELECT * FROM user_transformed
