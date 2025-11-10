{{ config(
    materialized='table'
) }}

-- Gold Dimension: User Dimension
-- Description: User profile and subscription information with SCD Type 2

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
        VALIDATION_STATUS
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED' OR VALIDATION_STATUS IS NULL
),

cleansed_users AS (
    SELECT 
        USER_ID,
        COALESCE(TRIM(USER_NAME), 'Unknown User') AS USER_NAME,
        COALESCE(LOWER(TRIM(EMAIL)), 'unknown@unknown.com') AS EMAIL,
        COALESCE(TRIM(INITCAP(COMPANY)), 'Unknown Company') AS COMPANY,
        COALESCE(UPPER(TRIM(PLAN_TYPE)), 'UNKNOWN') AS PLAN_TYPE,
        COALESCE(LOAD_DATE, CURRENT_DATE) AS LOAD_DATE,
        COALESCE(UPDATE_DATE, CURRENT_DATE) AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_users
),

enriched_users AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY USER_ID, LOAD_DATE) AS USER_DIM_ID,
        USER_NAME,
        CASE 
            WHEN EMAIL LIKE '%@%' THEN SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1)
            ELSE 'unknown.com'
        END AS EMAIL_DOMAIN,
        COMPANY,
        PLAN_TYPE,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS PLAN_CATEGORY,
        LOAD_DATE AS REGISTRATION_DATE,
        'Active' AS USER_STATUS,
        'Unknown' AS GEOGRAPHIC_REGION,
        'Unknown' AS INDUSTRY_SECTOR,
        'User' AS USER_ROLE,
        'Standard' AS ACCOUNT_TYPE,
        'UTC' AS TIME_ZONE,
        'English' AS LANGUAGE_PREFERENCE,
        LOAD_DATE AS EFFECTIVE_START_DATE,
        LEAD(LOAD_DATE, 1, '9999-12-31'::DATE) OVER (PARTITION BY USER_ID ORDER BY LOAD_DATE) AS EFFECTIVE_END_DATE,
        CASE WHEN LEAD(LOAD_DATE, 1) OVER (PARTITION BY USER_ID ORDER BY LOAD_DATE) IS NULL THEN TRUE ELSE FALSE END AS IS_CURRENT_RECORD,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM cleansed_users
)

SELECT * FROM enriched_users
