{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ target.schema }}.SI_PIPELINE_AUDIT (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, EXECUTED_BY, EXECUTION_ENVIRONMENT) VALUES (GENERATE_UUID(), 'SI_USERS_TRANSFORM', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_USERS', 'DBT_SYSTEM', 'PRODUCTION')",
    post_hook="UPDATE {{ target.schema }}.SI_PIPELINE_AUDIT SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_USERS_TRANSFORM' AND STATUS = 'RUNNING'"
) }}

-- Silver Layer Users Transformation
-- Source: Bronze.BZ_USERS
-- Target: Silver.SI_USERS
-- Description: Clean, validate and standardize user data with data quality checks

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
    FROM {{ ref('bz_users') }}
    WHERE USER_ID IS NOT NULL
),

-- Data Quality Validation and Cleansing
validated_users AS (
    SELECT 
        USER_ID,
        -- Clean and standardize user name
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'Unknown User'
            ELSE TRIM(UPPER(USER_NAME))
        END AS USER_NAME,
        
        -- Validate and standardize email
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN NULL
            WHEN REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                THEN LOWER(TRIM(EMAIL))
            ELSE NULL
        END AS EMAIL,
        
        -- Clean company name
        CASE 
            WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' THEN 'Unknown Company'
            ELSE TRIM(COMPANY)
        END AS COMPANY,
        
        -- Standardize plan type
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        
        -- Derive registration date from load timestamp
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        
        -- Derive last login date from update timestamp
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        
        -- Derive account status from plan type
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0.25 ELSE 0 END +
            CASE WHEN USER_NAME IS NOT NULL AND TRIM(USER_NAME) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_users
    WHERE EMAIL IS NULL OR REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
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
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50  -- Only include records with acceptable quality
