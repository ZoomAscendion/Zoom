{{ config(
    materialized='table'
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
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_users') }}
    WHERE USER_ID IS NOT NULL
),

user_transformed AS (
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
        'Active' AS USER_STATUS,
        'Unknown' AS GEOGRAPHIC_REGION,
        'Unknown' AS INDUSTRY_SECTOR,
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
