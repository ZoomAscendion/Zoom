{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (execution_id, pipeline_name, start_time, status, executed_by, source_tables_processed, target_tables_updated, load_date, update_date, source_system) SELECT CONCAT('USER_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')), 'SI_USERS_ETL', CURRENT_TIMESTAMP(), 'Started', 'DBT_PIPELINE', 'BZ_USERS', 'SI_USERS', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (execution_id, pipeline_name, end_time, status, executed_by, records_processed, load_date, update_date, source_system) SELECT CONCAT('USER_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')), 'SI_USERS_ETL', CURRENT_TIMESTAMP(), 'Completed', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Users Table
-- Transforms Bronze users data with data quality validations and standardization

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

-- Data Quality Validations
validated_users AS (
    SELECT 
        user_id,
        -- Standardize user name
        CASE 
            WHEN user_name IS NULL OR TRIM(user_name) = '' THEN 'Unknown User'
            ELSE TRIM(UPPER(user_name))
        END AS user_name,
        
        -- Validate and standardize email
        CASE 
            WHEN email IS NULL OR TRIM(email) = '' THEN NULL
            WHEN REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                THEN LOWER(TRIM(email))
            ELSE NULL
        END AS email,
        
        -- Standardize company
        CASE 
            WHEN company IS NULL OR TRIM(company) = '' THEN 'Unknown Company'
            ELSE TRIM(company)
        END AS company,
        
        -- Standardize plan type
        CASE 
            WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN plan_type
            ELSE 'Unknown Plan'
        END AS plan_type,
        
        -- Derive registration date from load timestamp
        DATE(load_timestamp) AS registration_date,
        
        -- Derive last login date from update timestamp
        DATE(update_timestamp) AS last_login_date,
        
        -- Derive account status
        CASE 
            WHEN plan_type IN ('Pro', 'Enterprise') THEN 'Active'
            WHEN plan_type = 'Basic' THEN 'Active'
            WHEN plan_type = 'Free' THEN 'Active'
            ELSE 'Inactive'
        END AS account_status,
        
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Calculate data quality score
        (
            CASE WHEN user_id IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN email IS NOT NULL AND REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0.25 ELSE 0 END +
            CASE WHEN user_name IS NOT NULL AND TRIM(user_name) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 0.25 ELSE 0 END
        ) AS data_quality_score
    FROM bronze_users
),

-- Remove duplicates - keep latest record
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY update_timestamp DESC) AS rn
    FROM validated_users
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
  AND email IS NOT NULL  -- Ensure no null emails in Silver layer
