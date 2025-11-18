{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('{{ invocation_id }}_user', 'go_dim_user', CURRENT_TIMESTAMP(), 'RUNNING', 'si_users', 'go_dim_user', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_ETL')",
    post_hook="UPDATE {{ ref('go_process_audit') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), UPDATE_DATE = CURRENT_DATE() WHERE AUDIT_LOG_ID = '{{ invocation_id }}_user'"
) }}

-- User dimension with enhanced attributes for analytics

WITH user_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_DATE,
        VALIDATION_STATUS,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY LOAD_TIMESTAMP DESC) AS rn
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY USER_ID) AS USER_DIM_ID,
    USER_ID,
    INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown User'))) AS USER_NAME,
    UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) AS EMAIL_DOMAIN,
    INITCAP(TRIM(COALESCE(COMPANY, 'Unknown Company'))) AS COMPANY,
    CASE 
        WHEN UPPER(COALESCE(PLAN_TYPE, '')) IN ('FREE', 'BASIC') THEN 'Basic'
        WHEN UPPER(COALESCE(PLAN_TYPE, '')) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
        WHEN UPPER(COALESCE(PLAN_TYPE, '')) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
        ELSE 'Unknown'
    END AS PLAN_TYPE,
    CASE 
        WHEN UPPER(COALESCE(PLAN_TYPE, '')) = 'FREE' THEN 'Free'
        ELSE 'Paid'
    END AS PLAN_CATEGORY,
    COALESCE(LOAD_DATE, CURRENT_DATE()) AS REGISTRATION_DATE,
    CASE 
        WHEN VALIDATION_STATUS = 'PASSED' THEN 'Active'
        ELSE 'Inactive'
    END AS USER_STATUS,
    CASE 
        WHEN UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.COM' THEN 'North America'
        WHEN UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.UK' 
             OR UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.EU' THEN 'Europe'
        ELSE 'Unknown'
    END AS GEOGRAPHIC_REGION,
    CASE 
        WHEN UPPER(COALESCE(COMPANY, '')) LIKE '%TECH%' OR UPPER(COALESCE(COMPANY, '')) LIKE '%SOFTWARE%' THEN 'Technology'
        WHEN UPPER(COALESCE(COMPANY, '')) LIKE '%BANK%' OR UPPER(COALESCE(COMPANY, '')) LIKE '%FINANCE%' THEN 'Financial Services'
        ELSE 'Unknown'
    END AS INDUSTRY_SECTOR,
    'Standard User' AS USER_ROLE,
    CASE 
        WHEN UPPER(COALESCE(PLAN_TYPE, '')) = 'FREE' THEN 'Individual'
        ELSE 'Business'
    END AS ACCOUNT_TYPE,
    'English' AS LANGUAGE_PREFERENCE,
    CURRENT_DATE() AS EFFECTIVE_START_DATE,
    '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
    TRUE AS IS_CURRENT_RECORD,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM user_data
WHERE rn = 1
