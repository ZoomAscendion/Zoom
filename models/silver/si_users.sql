{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_USERS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_USERS_ETL', CURRENT_TIMESTAMP(), 'Started', 'BZ_USERS', 'SI_USERS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_USERS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_USERS_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Users Table - Cleaned and standardized user data
-- Applies data quality validations and transformations from Bronze layer

WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Validation and Cleansing
users_cleaned AS (
    SELECT
        user_id,
        -- Standardize user name with proper case formatting
        CASE 
            WHEN user_name IS NULL OR TRIM(user_name) = '' THEN 'Unknown User'
            ELSE TRIM(UPPER(user_name))
        END AS user_name,
        
        -- Email validation and standardization
        CASE 
            WHEN email IS NULL OR TRIM(email) = '' THEN NULL
            WHEN REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                THEN LOWER(TRIM(email))
            ELSE NULL
        END AS email,
        
        -- Company standardization
        CASE 
            WHEN company IS NULL OR TRIM(company) = '' THEN 'Unknown Company'
            ELSE TRIM(company)
        END AS company,
        
        -- Plan type standardization
        CASE 
            WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN plan_type
            ELSE 'Unknown'
        END AS plan_type,
        
        -- Derive registration date from load timestamp
        DATE(load_timestamp) AS registration_date,
        
        -- Derive last login date from update timestamp
        DATE(update_timestamp) AS last_login_date,
        
        -- Derive account status from plan type and activity
        CASE 
            WHEN plan_type IN ('Pro', 'Enterprise') THEN 'Active'
            WHEN plan_type = 'Basic' THEN 'Active'
            WHEN plan_type = 'Free' THEN 'Active'
            ELSE 'Inactive'
        END AS account_status,
        
        -- Metadata columns
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN user_id IS NOT NULL 
                AND email IS NOT NULL 
                AND REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise')
                AND user_name IS NOT NULL AND TRIM(user_name) != ''
                THEN 1.00
            WHEN user_id IS NOT NULL AND email IS NOT NULL
                THEN 0.75
            WHEN user_id IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
        
    FROM bronze_users
    WHERE user_id IS NOT NULL  -- Block records without user_id
),

-- Remove duplicates - keep latest record
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
    AND data_quality_score >= 0.50  -- Only high quality records
