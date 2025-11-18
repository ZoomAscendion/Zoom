{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, LOAD_DATE, SOURCE_SYSTEM) VALUES ('{{ invocation_id }}', 'go_dim_user', 'SILVER.SI_USERS', 'GOLD.GO_DIM_USER', CURRENT_TIMESTAMP(), 'RUNNING', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), UPDATE_DATE = CURRENT_DATE() WHERE AUDIT_LOG_ID = '{{ invocation_id }}' AND PROCESS_NAME = 'go_dim_user'"
) }}

-- User dimension transformation from Silver to Gold layer
WITH user_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_DATE,
        VALIDATION_STATUS,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_users') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
      AND USER_ID IS NOT NULL
),

user_transformed AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY USER_ID) AS USER_DIM_ID,
        USER_ID,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown User'))) AS USER_NAME,
        UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) AS EMAIL_DOMAIN,
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown Company'))) AS COMPANY,
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) = 'FREE' THEN 'Free'
            ELSE 'Paid'
        END AS PLAN_CATEGORY,
        COALESCE(LOAD_DATE, CURRENT_DATE()) AS REGISTRATION_DATE,
        CASE 
            WHEN COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED' THEN 'Active'
            ELSE 'Inactive'
        END AS USER_STATUS,
        CASE 
            WHEN UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.COM' THEN 'North America'
            WHEN UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.UK' 
                 OR UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.EU' THEN 'Europe'
            ELSE 'Unknown'
        END AS GEOGRAPHIC_REGION,
        CASE 
            WHEN UPPER(COALESCE(COMPANY, 'UNKNOWN')) LIKE '%TECH%' OR UPPER(COALESCE(COMPANY, 'UNKNOWN')) LIKE '%SOFTWARE%' THEN 'Technology'
            WHEN UPPER(COALESCE(COMPANY, 'UNKNOWN')) LIKE '%BANK%' OR UPPER(COALESCE(COMPANY, 'UNKNOWN')) LIKE '%FINANCE%' THEN 'Financial Services'
            ELSE 'Unknown'
        END AS INDUSTRY_SECTOR,
        'Standard User' AS USER_ROLE,
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) = 'FREE' THEN 'Individual'
            ELSE 'Business'
        END AS ACCOUNT_TYPE,
        'English' AS LANGUAGE_PREFERENCE,
        CURRENT_DATE() AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM user_data
)

SELECT * FROM user_transformed
