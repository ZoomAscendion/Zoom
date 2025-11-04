{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_USERS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_USERS_ETL', CURRENT_TIMESTAMP(), 'Started', 'BZ_USERS', 'SI_USERS', 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_USERS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_USERS_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')"
) }}

-- Silver Layer Users Table
-- Transforms Bronze users data with data quality validations and standardization

WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Validations
validated_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Data Quality Flags
        CASE 
            WHEN user_id IS NULL THEN 'CRITICAL_MISSING_ID'
            WHEN email IS NULL OR TRIM(email) = '' THEN 'CRITICAL_MISSING_EMAIL'
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 'CRITICAL_INVALID_EMAIL'
            ELSE 'VALID'
        END AS data_quality_status,
        
        -- Calculate data quality score
        CASE 
            WHEN user_id IS NOT NULL 
                AND email IS NOT NULL 
                AND TRIM(email) != '' 
                AND REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
                AND user_name IS NOT NULL
                AND plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN 1.00
            ELSE 0.75
        END AS data_quality_score,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY update_timestamp DESC, load_timestamp DESC) AS rn
    FROM bronze_users
    WHERE user_id IS NOT NULL  -- Block records without user_id
        AND email IS NOT NULL 
        AND TRIM(email) != ''
        AND REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
),

-- Apply transformations
transformed_users AS (
    SELECT 
        user_id,
        TRIM(UPPER(user_name)) AS user_name,
        LOWER(TRIM(email)) AS email,
        TRIM(INITCAP(company)) AS company,
        CASE 
            WHEN UPPER(plan_type) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN INITCAP(plan_type)
            ELSE 'Unknown'
        END AS plan_type,
        
        -- Derived fields
        DATE(load_timestamp) AS registration_date,
        DATE(update_timestamp) AS last_login_date,
        CASE 
            WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'Active'
            ELSE 'Inactive'
        END AS account_status,
        
        -- Metadata columns
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_users
    WHERE rn = 1  -- Keep only the latest record for each user
        AND data_quality_status = 'VALID'
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
FROM transformed_users
