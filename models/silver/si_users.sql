{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_USERS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_USERS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_USERS', 'SI_USERS', 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, records_inserted, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_USERS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_USERS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Users Model
-- Transforms bronze user data with data quality validations and standardization

WITH bronze_users AS (
    SELECT * FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Validation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Email validation
        CASE 
            WHEN email IS NULL OR TRIM(email) = '' THEN 'MISSING_EMAIL'
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 'INVALID_EMAIL_FORMAT'
            ELSE 'VALID'
        END AS email_quality_flag,
        
        -- Plan type validation
        CASE 
            WHEN plan_type NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'INVALID_PLAN_TYPE'
            ELSE 'VALID'
        END AS plan_type_quality_flag,
        
        -- Temporal validation
        CASE 
            WHEN load_timestamp > CURRENT_TIMESTAMP() + INTERVAL '1' DAY THEN 'FUTURE_TIMESTAMP'
            WHEN update_timestamp < load_timestamp THEN 'TEMPORAL_ANOMALY'
            ELSE 'VALID'
        END AS temporal_quality_flag
    FROM bronze_users
    WHERE user_id IS NOT NULL  -- Block records without user_id
),

-- Data Cleansing and Standardization
cleansed_users AS (
    SELECT 
        -- Primary identifier
        user_id,
        
        -- Standardized business columns
        TRIM(UPPER(user_name)) AS user_name,
        CASE 
            WHEN email_quality_flag = 'VALID' THEN LOWER(TRIM(email))
            ELSE NULL
        END AS email,
        TRIM(INITCAP(company)) AS company,
        CASE 
            WHEN plan_type_quality_flag = 'VALID' THEN plan_type
            ELSE 'Unknown'
        END AS plan_type,
        
        -- Derived business columns
        DATE(load_timestamp) AS registration_date,
        DATE(update_timestamp) AS last_login_date,
        CASE 
            WHEN plan_type IN ('Pro', 'Enterprise') THEN 'Active'
            WHEN plan_type = 'Free' THEN 'Active'
            ELSE 'Inactive'
        END AS account_status,
        
        -- Silver layer metadata
        CASE 
            WHEN temporal_quality_flag = 'FUTURE_TIMESTAMP' THEN CURRENT_TIMESTAMP()
            ELSE load_timestamp
        END AS load_timestamp,
        CASE 
            WHEN temporal_quality_flag = 'TEMPORAL_ANOMALY' THEN GREATEST(update_timestamp, load_timestamp)
            ELSE update_timestamp
        END AS update_timestamp,
        source_system,
        
        -- Data quality score calculation
        ROUND(
            (CASE WHEN email_quality_flag = 'VALID' THEN 0.4 ELSE 0.0 END +
             CASE WHEN plan_type_quality_flag = 'VALID' THEN 0.3 ELSE 0.0 END +
             CASE WHEN temporal_quality_flag = 'VALID' THEN 0.2 ELSE 0.0 END +
             CASE WHEN user_name IS NOT NULL AND TRIM(user_name) != '' THEN 0.1 ELSE 0.0 END), 2
        ) AS data_quality_score,
        
        -- Standard metadata
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
        
    FROM data_quality_checks
    WHERE email_quality_flag != 'MISSING_EMAIL'  -- Block users without email
),

-- Deduplication layer
deduped_users AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY update_timestamp DESC) AS rn
    FROM cleansed_users
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
FROM deduped_users
WHERE rn = 1  -- Keep only the latest version of each user
