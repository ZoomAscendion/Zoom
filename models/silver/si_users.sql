{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_SI_USERS_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING), 'SILVER_SI_USERS', CURRENT_TIMESTAMP(), 'In Progress', 'DBT_SILVER_PIPELINE', CURRENT_DATE(), CURRENT_DATE(), 'BRONZE_BZ_USERS' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'Success', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SILVER_SI_USERS' AND STATUS = 'In Progress'"
) }}

-- Silver Layer Users Table
-- Transforms Bronze users data with data quality validations and standardization

WITH bronze_users AS (
    SELECT *
    FROM {{ ref('bz_users') }}
    WHERE USER_ID IS NOT NULL  -- Basic null check for primary identifier
),

-- Data Quality Checks and Transformations
users_cleaned AS (
    SELECT 
        -- Primary identifier (direct mapping with validation)
        USER_ID,
        
        -- Standardized user name with proper case formatting
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'Unknown User'
            ELSE TRIM(UPPER(USER_NAME))
        END AS USER_NAME,
        
        -- Email validation and standardization
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN NULL
            WHEN REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
                THEN LOWER(TRIM(EMAIL))
            ELSE NULL
        END AS EMAIL,
        
        -- Company standardization
        CASE 
            WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' THEN 'Unknown Company'
            ELSE TRIM(INITCAP(COMPANY))
        END AS COMPANY,
        
        -- Plan type standardization
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        
        -- Derived fields
        LOAD_TIMESTAMP::DATE AS REGISTRATION_DATE,
        UPDATE_TIMESTAMP::DATE AS LAST_LOGIN_DATE,
        
        -- Account status derivation
        CASE 
            WHEN PLAN_TYPE IN ('Pro', 'Enterprise') THEN 'Active'
            WHEN PLAN_TYPE = 'Free' THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME IS NOT NULL AND TRIM(USER_NAME) != ''
                AND EMAIL IS NOT NULL AND REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
                THEN 1.00
            WHEN USER_ID IS NOT NULL AND USER_NAME IS NOT NULL
                THEN 0.75
            WHEN USER_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        UPDATE_TIMESTAMP::DATE AS UPDATE_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
        
    FROM bronze_users
),

-- Final deduplication
users_final AS (
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
    FROM users_cleaned
    WHERE rn = 1  -- Keep only the latest record per user
        AND EMAIL IS NOT NULL  -- Ensure no null emails in Silver layer
)

SELECT * FROM users_final
