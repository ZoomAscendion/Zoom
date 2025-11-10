{{ config(
    materialized='table'
) }}

-- User Dimension Table with SCD Type 2
-- Transforms Silver layer user data into business-ready dimension

WITH user_base AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        LOAD_DATE,
        SOURCE_SYSTEM,
        VALIDATION_STATUS,
        DATA_QUALITY_SCORE
    FROM SILVER.SI_USERS
    WHERE VALIDATION_STATUS = 'PASSED'
        AND DATA_QUALITY_SCORE >= 80
),

license_info AS (
    SELECT 
        ASSIGNED_TO_USER_ID,
        LICENSE_ID,
        END_DATE
    FROM SILVER.SI_LICENSES
    WHERE VALIDATION_STATUS = 'PASSED'
),

user_transformations AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY u.USER_ID, u.LOAD_TIMESTAMP) AS USER_DIM_ID,
        COALESCE(TRIM(UPPER(u.USER_NAME)), 'Unknown User') AS USER_NAME,
        CASE 
            WHEN u.EMAIL IS NOT NULL AND u.EMAIL LIKE '%@%' THEN 
                LOWER(SUBSTRING(u.EMAIL, POSITION('@' IN u.EMAIL) + 1))
            ELSE 'unknown-domain.com'
        END AS EMAIL_DOMAIN,
        COALESCE(TRIM(INITCAP(u.COMPANY)), 'Unknown Company') AS COMPANY,
        COALESCE(UPPER(TRIM(u.PLAN_TYPE)), 'Unknown Plan') AS PLAN_TYPE,
        CASE 
            WHEN UPPER(u.PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(u.PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(u.PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS PLAN_CATEGORY,
        COALESCE(u.LOAD_DATE, CURRENT_DATE()) AS REGISTRATION_DATE,
        CASE 
            WHEN l.LICENSE_ID IS NOT NULL AND l.END_DATE >= CURRENT_DATE() THEN 'Active'
            WHEN l.LICENSE_ID IS NOT NULL AND l.END_DATE < CURRENT_DATE() THEN 'Expired'
            ELSE 'Inactive'
        END AS USER_STATUS,
        'North America' AS GEOGRAPHIC_REGION,
        'Technology' AS INDUSTRY_SECTOR,
        'Standard User' AS USER_ROLE,
        'Individual' AS ACCOUNT_TYPE,
        'UTC' AS TIME_ZONE,
        'English' AS LANGUAGE_PREFERENCE,
        u.LOAD_DATE AS EFFECTIVE_START_DATE,
        LEAD(u.LOAD_DATE, 1, '9999-12-31'::DATE) OVER (
            PARTITION BY u.USER_ID ORDER BY u.LOAD_DATE
        ) AS EFFECTIVE_END_DATE,
        CASE 
            WHEN LEAD(u.LOAD_DATE, 1) OVER (
                PARTITION BY u.USER_ID ORDER BY u.LOAD_DATE
            ) IS NULL THEN TRUE 
            ELSE FALSE 
        END AS IS_CURRENT_RECORD,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        u.SOURCE_SYSTEM
    FROM user_base u
    LEFT JOIN license_info l ON u.USER_ID = l.ASSIGNED_TO_USER_ID
)

SELECT * FROM user_transformations
ORDER BY USER_DIM_ID
