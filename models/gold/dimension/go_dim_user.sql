{{ config(
    materialized='table'
) }}

-- User Dimension Table
-- Dimension table containing user profile and subscription information

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
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY USER_ID) AS USER_DIM_ID,
    USER_ID,
    COALESCE(INITCAP(TRIM(USER_NAME)), 'Unknown User') AS USER_NAME,
    CASE 
        WHEN EMAIL IS NOT NULL AND POSITION('@' IN EMAIL) > 0 
        THEN UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1))
        ELSE 'unknown.com'
    END AS EMAIL_DOMAIN,
    COALESCE(INITCAP(TRIM(COMPANY)), 'Unknown Company') AS COMPANY,
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
    'Unknown' AS GEOGRAPHIC_REGION,
    'Unknown' AS INDUSTRY_SECTOR,
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
