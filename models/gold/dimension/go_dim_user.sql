{{ config(
    materialized='table'
) }}

-- User Dimension Table
WITH user_data AS (
    SELECT 
        'USER_001' AS USER_ID,
        'John Doe' AS USER_NAME,
        'john.doe@company.com' AS EMAIL,
        'Tech Corp' AS COMPANY,
        'Pro' AS PLAN_TYPE,
        'PASSED' AS VALIDATION_STATUS,
        95 AS DATA_QUALITY_SCORE,
        'SYSTEM' AS SOURCE_SYSTEM
    UNION ALL
    SELECT 
        'USER_002' AS USER_ID,
        'Jane Smith' AS USER_NAME,
        'jane.smith@enterprise.com' AS EMAIL,
        'Enterprise Inc' AS COMPANY,
        'Enterprise' AS PLAN_TYPE,
        'PASSED' AS VALIDATION_STATUS,
        98 AS DATA_QUALITY_SCORE,
        'SYSTEM' AS SOURCE_SYSTEM
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY USER_ID) AS USER_DIM_ID,
    USER_ID,
    COALESCE(TRIM(UPPER(USER_NAME)), 'Unknown User') AS USER_NAME,
    CASE 
        WHEN EMAIL IS NOT NULL AND EMAIL LIKE '%@%' THEN 
            LOWER(TRIM(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1)))
        ELSE 'Unknown Domain'
    END AS EMAIL_DOMAIN,
    COALESCE(TRIM(INITCAP(COMPANY)), 'Unknown Company') AS COMPANY,
    UPPER(TRIM(PLAN_TYPE)) AS PLAN_TYPE,
    CASE 
        WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic'
        WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
        WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
        ELSE 'Other'
    END AS PLAN_CATEGORY,
    CURRENT_DATE() AS REGISTRATION_DATE,
    'Active' AS USER_STATUS,
    'North America' AS GEOGRAPHIC_REGION,
    'Technology' AS INDUSTRY_SECTOR,
    'End User' AS USER_ROLE,
    'Standard' AS ACCOUNT_TYPE,
    'UTC' AS TIME_ZONE,
    'English' AS LANGUAGE_PREFERENCE,
    CURRENT_DATE() AS EFFECTIVE_START_DATE,
    '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
    TRUE AS IS_CURRENT_RECORD,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM user_data
WHERE VALIDATION_STATUS = 'PASSED'
    AND DATA_QUALITY_SCORE >= 80
