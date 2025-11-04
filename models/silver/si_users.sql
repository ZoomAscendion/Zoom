{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.si_pipeline_audit (execution_id, pipeline_name, start_time, status, executed_by) VALUES (REPLACE(UUID_STRING(), '-', ''), 'si_users_transform', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_USER())",
    post_hook="UPDATE {{ this.database }}.{{ this.schema }}.si_pipeline_audit SET end_time = CURRENT_TIMESTAMP(), status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE pipeline_name = 'si_users_transform' AND status = 'STARTED'"
) }}

-- Silver Layer Users Transformation
-- Source: Bronze.BZ_USERS
-- Target: Silver.SI_USERS
-- Description: Transforms and cleanses user data with comprehensive data quality checks

WITH bronze_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ ref('bronze_users') }}
    WHERE user_id IS NOT NULL
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        user_id,
        -- Standardize user name with proper case formatting
        CASE 
            WHEN user_name IS NULL OR TRIM(user_name) = '' THEN 'Unknown User'
            ELSE TRIM(UPPER(SUBSTRING(user_name, 1, 1)) || LOWER(SUBSTRING(user_name, 2)))
        END AS user_name_clean,
        
        -- Email validation and standardization
        CASE 
            WHEN email IS NULL OR TRIM(email) = '' THEN NULL
            WHEN REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
                THEN LOWER(TRIM(email))
            ELSE NULL
        END AS email_clean,
        
        -- Company standardization
        CASE 
            WHEN company IS NULL OR TRIM(company) = '' THEN 'Unknown Company'
            ELSE TRIM(company)
        END AS company_clean,
        
        -- Plan type standardization
        CASE 
            WHEN UPPER(plan_type) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN UPPER(plan_type)
            ELSE 'UNKNOWN_PLAN'
        END AS plan_type_clean,
        
        -- Derive registration date from load timestamp
        DATE(load_timestamp) AS registration_date,
        
        -- Derive last login date from update timestamp
        DATE(update_timestamp) AS last_login_date,
        
        -- Derive account status from plan type and activity
        CASE 
            WHEN plan_type IS NOT NULL AND update_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 'Active'
            WHEN plan_type IS NOT NULL AND update_timestamp < DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 'Inactive'
            ELSE 'Suspended'
        END AS account_status,
        
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_users
),

-- Calculate data quality score
quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score based on completeness and validity
        (
            CASE WHEN user_name_clean != 'Unknown User' THEN 0.25 ELSE 0 END +
            CASE WHEN email_clean IS NOT NULL THEN 0.30 ELSE 0 END +
            CASE WHEN company_clean != 'Unknown Company' THEN 0.20 ELSE 0 END +
            CASE WHEN plan_type_clean != 'UNKNOWN_PLAN' THEN 0.25 ELSE 0 END
        ) AS data_quality_score
    FROM data_quality_checks
),

-- Remove duplicates keeping the most recent record
deduped_users AS (
    SELECT 
        user_id,
        user_name_clean AS user_name,
        email_clean AS email,
        company_clean AS company,
        plan_type_clean AS plan_type,
        registration_date,
        last_login_date,
        account_status,
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY update_timestamp DESC) AS rn
    FROM quality_scored
    WHERE data_quality_score >= {{ var('dq_score_threshold') }}
)

SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    registration_date,
    last_login_date,
    account_status,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    DATE(load_timestamp) AS load_date,
    DATE(update_timestamp) AS update_date
FROM deduped_users
WHERE rn = 1
  AND email IS NOT NULL  -- Ensure no null emails in silver layer
