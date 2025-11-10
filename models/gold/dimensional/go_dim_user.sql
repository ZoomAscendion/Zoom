{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_DIM_USER_TRANSFORMATION', 'SI_USERS', 'GO_DIM_USER', CURRENT_TIMESTAMP(), 'STARTED', 'User dimension transformation started', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_DIM_USER_TRANSFORMATION', 'SI_USERS', 'GO_DIM_USER', CURRENT_TIMESTAMP(), 'COMPLETED', 'User dimension transformation completed successfully', CURRENT_DATE(), CURRENT_DATE())"
) }}

-- User Dimension Table with SCD Type 2
-- Transforms Silver layer user data into business-ready dimension

WITH user_transformations AS (
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
    FROM {{ source('silver', 'si_users') }} u
    LEFT JOIN {{ source('silver', 'si_licenses') }} l 
        ON u.USER_ID = l.ASSIGNED_TO_USER_ID
    WHERE u.VALIDATION_STATUS = 'PASSED'
        AND u.DATA_QUALITY_SCORE >= 80
)

SELECT * FROM user_transformations
ORDER BY USER_DIM_ID
