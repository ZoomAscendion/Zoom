{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ log("Starting transformation for si_users", info=True) }}
{% endif %}

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
        s.*,
        -- Email validation
        CASE 
            WHEN s.EMAIL IS NULL OR TRIM(s.EMAIL) = '' THEN 0
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(s.EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0
            ELSE 1
        END AS email_valid,
        
        -- Plan type validation
        CASE 
            WHEN s.PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 1
            ELSE 0
        END AS plan_type_valid,
        
        -- Completeness check
        CASE 
            WHEN s.USER_NAME IS NOT NULL AND TRIM(s.USER_NAME) != '' THEN 1
            ELSE 0
        END AS name_complete
    FROM source_data s
),

cleaned_data AS (
    SELECT 
        USER_ID,
        
        -- Standardize user name
        CASE 
            WHEN USER_NAME IS NOT NULL AND TRIM(USER_NAME) != '' 
            THEN TRIM(UPPER(USER_NAME))
            ELSE 'UNKNOWN_USER'
        END AS USER_NAME,
        
        -- Clean and validate email
        CASE 
            WHEN email_valid = 1 
            THEN LOWER(TRIM(EMAIL))
            ELSE NULL
        END AS EMAIL,
        
        -- Standardize company
        CASE 
            WHEN COMPANY IS NOT NULL AND TRIM(COMPANY) != '' 
            THEN TRIM(COMPANY)
            ELSE 'UNKNOWN_COMPANY'
        END AS COMPANY,
        
        -- Standardize plan type
        CASE 
            WHEN plan_type_valid = 1 THEN PLAN_TYPE
            ELSE 'UNKNOWN_PLAN'
        END AS PLAN_TYPE,
        
        -- Derive registration date from load timestamp
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        
        -- Derive last login date from update timestamp
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        
        -- Derive account status from plan type and activity
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        
        -- Calculate data quality score
        ROUND((email_valid + plan_type_valid + name_complete) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM data_quality_checks
    WHERE USER_ID IS NOT NULL  -- Remove records with null primary key
),

deduplication AS (
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
    created_at,
    updated_at
FROM deduplication

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ log("Completed transformation for si_users", info=True) }}
{% endif %}
