{{ config(
    materialized='table'
) }}

-- User Dimension Table
-- Transforms Silver layer user data into Gold dimension with enhanced attributes

WITH source_users AS (
    SELECT *
    FROM {{ source('silver', 'si_users') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

user_transformations AS (
    SELECT 
        MD5(COALESCE(USER_ID, 'UNKNOWN_USER')) AS USER_KEY,
        ROW_NUMBER() OVER (ORDER BY COALESCE(USER_ID, 'UNKNOWN_USER')) AS USER_DIM_ID,
        COALESCE(USER_ID, 'UNKNOWN_USER') AS USER_ID,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown User'))) AS USER_NAME,
        CASE 
            WHEN EMAIL IS NOT NULL AND POSITION('@' IN EMAIL) > 0
            THEN UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1))
            ELSE 'UNKNOWN_DOMAIN'
        END AS EMAIL_DOMAIN,
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
        'Unknown' AS GEOGRAPHIC_REGION,
        'Unknown' AS INDUSTRY_SECTOR,
        'Unknown' AS USER_ROLE,
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
    FROM source_users
),

deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE 
            ORDER BY REGISTRATION_DATE DESC
        ) AS rn
    FROM user_transformations
)

SELECT 
    USER_KEY,
    USER_DIM_ID,
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
FROM deduped_users
WHERE rn = 1
