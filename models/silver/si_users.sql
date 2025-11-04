{{ config(
    materialized='table'
) }}

-- Silver Users Model - Cleaned and standardized user data
-- Transforms Bronze user data with data quality validations and standardization

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
    FROM {{ source('bronze', 'bz_users') }}
    WHERE user_id IS NOT NULL
),

-- Data Quality Checks and Cleansing
users_cleaned AS (
    SELECT 
        user_id,
        -- Standardize user name with proper case formatting
        CASE 
            WHEN user_name IS NULL OR TRIM(user_name) = '' 
            THEN 'Unknown User'
            ELSE TRIM(UPPER(user_name))
        END AS user_name,
        
        -- Validate and standardize email
        CASE 
            WHEN email IS NULL OR TRIM(email) = '' THEN NULL
            WHEN REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
            THEN LOWER(TRIM(email))
            ELSE NULL
        END AS email,
        
        -- Standardize company name
        CASE 
            WHEN company IS NULL OR TRIM(company) = '' 
            THEN 'Unknown Company'
            ELSE TRIM(company)
        END AS company,
        
        -- Standardize plan type to enumerated values
        CASE 
            WHEN UPPER(plan_type) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(plan_type)
            ELSE 'UNKNOWN_PLAN'
        END AS plan_type,
        
        -- Derive registration date from load timestamp
        DATE(load_timestamp) AS registration_date,
        
        -- Derive last login date from update timestamp
        DATE(update_timestamp) AS last_login_date,
        
        -- Derive account status from plan type and activity
        CASE 
            WHEN plan_type IS NOT NULL AND plan_type != '' 
            THEN 'Active'
            ELSE 'Inactive'
        END AS account_status,
        
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN user_id IS NOT NULL 
                 AND user_name IS NOT NULL AND TRIM(user_name) != ''
                 AND email IS NOT NULL 
                 AND REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                 AND plan_type IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN 1.00
            WHEN user_id IS NOT NULL AND user_name IS NOT NULL
            THEN 0.75
            WHEN user_id IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM bronze_users
),

-- Remove duplicates keeping the latest record
users_deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY update_timestamp DESC) AS rn
    FROM users_cleaned
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
    load_date,
    update_date
FROM users_deduped
WHERE rn = 1
  AND email IS NOT NULL  -- Ensure no null emails in Silver layer
  AND data_quality_score >= 0.50  -- Minimum quality threshold
