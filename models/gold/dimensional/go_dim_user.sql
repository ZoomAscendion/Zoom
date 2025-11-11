{{ config(
    materialized='table',
    tags=['dimension', 'gold']
) }}

-- User Dimension transformation from Silver layer
WITH user_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        SOURCE_SYSTEM,
        LOAD_DATE,
        VALIDATION_STATUS
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND USER_ID IS NOT NULL
),

user_transformed AS (
    SELECT 
        MD5(USER_ID) AS USER_KEY,
        USER_ID,
        COALESCE(INITCAP(TRIM(USER_NAME)), 'Unknown') AS USER_NAME,
        CASE 
            WHEN EMAIL IS NOT NULL AND POSITION('@' IN EMAIL) > 0 
            THEN UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1))
            ELSE 'Unknown'
        END AS EMAIL_DOMAIN,
        COALESCE(INITCAP(TRIM(COMPANY)), 'Unknown') AS COMPANY,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        CASE 
            WHEN UPPER(PLAN_TYPE) = 'FREE' THEN 'Free'
            ELSE 'Paid'
        END AS PLAN_CATEGORY,
        COALESCE(LOAD_DATE, CURRENT_DATE()) AS REGISTRATION_DATE,
        'Active' AS USER_STATUS,
        'Unknown' AS GEOGRAPHIC_REGION,
        'Unknown' AS INDUSTRY_SECTOR,
        'All Users' AS USER_ROLE,
        CASE 
            WHEN UPPER(PLAN_TYPE) = 'FREE' THEN 'Individual'
            ELSE 'Business'
        END AS ACCOUNT_TYPE,
        'English' AS LANGUAGE_PREFERENCE,
        CURRENT_DATE() AS EFFECTIVE_START_DATE,
        DATE('9999-12-31') AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM user_data
)

SELECT 
    USER_KEY,
    ROW_NUMBER() OVER (ORDER BY USER_KEY) AS USER_DIM_ID,
    USER_ID,
    USER_NAME,
    EMAIL_DOMAIN,
    COMPANY,
    PLAN_TYPE,
    PLAN_CATEGORY,
    REGISTRATION_DATE,
    USER_STATUS,
    GEOGRAPHIC_REGION,
    INDUSTRY_SECTOR,
    USER_ROLE,
    ACCOUNT_TYPE,
    LANGUAGE_PREFERENCE,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    IS_CURRENT_RECORD,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM user_transformed
