{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Users
-- Source: BRONZE.BZ_USERS -> Target: SILVER.SI_USERS
-- Includes data quality validations and standardization

WITH source_data AS (
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

data_quality_checks AS (
    SELECT 
        *,
        -- Email validation
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN 0
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$') THEN 0
            ELSE 1
        END AS email_valid,
        
        -- Plan type validation
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 1
            ELSE 0
        END AS plan_type_valid,
        
        -- User name validation
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 0
            ELSE 1
        END AS user_name_valid
    FROM source_data
),

cleaned_data AS (
    SELECT 
        USER_ID,
        
        -- Standardized user name
        CASE 
            WHEN user_name_valid = 1 THEN TRIM(UPPER(USER_NAME))
            ELSE 'UNKNOWN_USER'
        END AS USER_NAME,
        
        -- Validated and standardized email
        CASE 
            WHEN email_valid = 1 THEN LOWER(TRIM(EMAIL))
            ELSE NULL
        END AS EMAIL,
        
        -- Standardized company
        CASE 
            WHEN COMPANY IS NOT NULL AND TRIM(COMPANY) != '' 
            THEN TRIM(INITCAP(COMPANY))
            ELSE 'Unknown'
        END AS COMPANY,
        
        -- Standardized plan type
        CASE 
            WHEN plan_type_valid = 1 THEN PLAN_TYPE
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        
        -- Derived fields
        COALESCE(DATE(LOAD_TIMESTAMP), '1900-01-01'::DATE) AS REGISTRATION_DATE,
        COALESCE(DATE(UPDATE_TIMESTAMP), CURRENT_DATE()) AS LAST_LOGIN_DATE,
        
        -- Account status derived from plan type and activity
        CASE 
            WHEN PLAN_TYPE IN ('Pro', 'Enterprise') THEN 'Active'
            WHEN PLAN_TYPE = 'Basic' THEN 'Active'
            WHEN PLAN_TYPE = 'Free' THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        
        -- Metadata
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        ROUND((email_valid + plan_type_valid + user_name_valid) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM data_quality_checks
    WHERE USER_ID IS NOT NULL  -- Remove records with null primary keys
),

-- Deduplication
deduplicated_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    UPDATE_DATE,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM deduplicated_data
WHERE DATA_QUALITY_SCORE >= 0.5  -- Only include records with acceptable quality
