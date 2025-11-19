{{ config(
    materialized='table',
    unique_key='USER_DIM_ID'
) }}

-- User dimension with SCD Type 2 implementation
-- Includes derived attributes for analytics

WITH source_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND DATA_QUALITY_SCORE >= 70
),

user_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY USER_ID) AS USER_DIM_ID,
        USER_ID,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown User'))) AS USER_NAME,
        CASE 
            WHEN EMAIL IS NOT NULL AND POSITION('@' IN EMAIL) > 0 
            THEN UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1))
            ELSE 'unknown.com'
        END AS EMAIL_DOMAIN,
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown Company'))) AS COMPANY,
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
        LOAD_DATE AS REGISTRATION_DATE,
        'Active' AS USER_STATUS,
        CASE 
            WHEN UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1)) LIKE '%.COM' THEN 'North America'
            WHEN UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1)) LIKE '%.UK' 
              OR UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1)) LIKE '%.EU' THEN 'Europe'
            WHEN UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1)) LIKE '%.IN' THEN 'Asia Pacific'
            ELSE 'Unknown'
        END AS GEOGRAPHIC_REGION,
        CASE 
            WHEN UPPER(COMPANY) LIKE '%TECH%' OR UPPER(COMPANY) LIKE '%SOFTWARE%' THEN 'Technology'
            WHEN UPPER(COMPANY) LIKE '%BANK%' OR UPPER(COMPANY) LIKE '%FINANCE%' THEN 'Financial Services'
            WHEN UPPER(COMPANY) LIKE '%HEALTH%' OR UPPER(COMPANY) LIKE '%MEDICAL%' THEN 'Healthcare'
            WHEN UPPER(COMPANY) LIKE '%EDU%' OR UPPER(COMPANY) LIKE '%SCHOOL%' THEN 'Education'
            ELSE 'Other'
        END AS INDUSTRY_SECTOR,
        'Standard User' AS USER_ROLE,
        CASE 
            WHEN UPPER(PLAN_TYPE) = 'FREE' THEN 'Individual'
            ELSE 'Business'
        END AS ACCOUNT_TYPE,
        'English' AS LANGUAGE_PREFERENCE,
        CURRENT_DATE() AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_users
)

SELECT * FROM user_dimension
