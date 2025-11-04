{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_USERS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_PIPELINE', 'BZ_USERS', 'SI_USERS', CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, EXECUTED_BY, RECORDS_PROCESSED, LOAD_DATE) SELECT 'EXEC_' || REPLACE(CAST(CURRENT_TIMESTAMP() AS STRING), ' ', '_'), 'SI_USERS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE() WHERE EXISTS (SELECT 1 FROM {{ ref('audit_log') }} LIMIT 1)"
) }}

-- Silver Layer Users Table Transformation
-- Source: Bronze.BZ_USERS
-- Applies data quality checks and standardization

WITH bronze_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_USERS') }}
),

-- Data Quality Validation and Cleansing
validated_users AS (
    SELECT 
        USER_ID,
        -- Standardize user name with proper case
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' 
            THEN 'Unknown User'
            ELSE TRIM(UPPER(LEFT(USER_NAME, 1)) || LOWER(SUBSTRING(USER_NAME, 2)))
        END AS USER_NAME,
        
        -- Email validation and standardization
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN NULL
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN NULL
            ELSE LOWER(TRIM(EMAIL))
        END AS EMAIL,
        
        -- Company standardization
        CASE 
            WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' 
            THEN 'Unknown Company'
            ELSE TRIM(COMPANY)
        END AS COMPANY,
        
        -- Plan type standardization
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Unknown Plan'
        END AS PLAN_TYPE,
        
        -- Derive registration date from load timestamp
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        
        -- Derive last login date from update timestamp
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        
        -- Derive account status from plan type and activity
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') AND UPDATE_TIMESTAMP >= DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 'Active'
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'Inactive'
            ELSE 'Suspended'
        END AS ACCOUNT_STATUS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME IS NOT NULL AND TRIM(USER_NAME) != ''
                AND EMAIL IS NOT NULL AND REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN 1.00
            WHEN USER_ID IS NOT NULL AND USER_NAME IS NOT NULL
            THEN 0.75
            WHEN USER_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_users
    WHERE USER_ID IS NOT NULL  -- Block records without USER_ID
)

-- Final selection with deduplication
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    REGISTRATION_DATE,
    LAST_LOGIN_DATE,
    ACCOUNT_STATUS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM validated_users
WHERE rn = 1  -- Keep only the latest record per USER_ID
    AND EMAIL IS NOT NULL  -- Block records with invalid email
