{{ config(
    materialized='table'
) }}

-- User Dimension Table with SCD Type 2
WITH user_source AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        ACCOUNT_STATUS,
        REGISTRATION_DATE,
        SOURCE_SYSTEM,
        COALESCE(DATA_QUALITY_SCORE, 1.0) AS DATA_QUALITY_SCORE
    FROM DB_POC_ZOOM.SILVER.SI_USERS
    WHERE COALESCE(DATA_QUALITY_SCORE, 1.0) >= 0.8
),

user_transformed AS (
    SELECT 
        'DIM_USER_' || USER_ID || '_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS') AS DIM_USER_ID,
        USER_ID AS USER_BUSINESS_KEY,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown'))) AS USER_NAME,
        UPPER(SPLIT_PART(COALESCE(EMAIL, 'unknown@unknown.com'), '@', 2)) AS EMAIL_DOMAIN,
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown'))) AS COMPANY_NAME,
        UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) AS PLAN_TYPE,
        UPPER(COALESCE(ACCOUNT_STATUS, 'UNKNOWN')) AS ACCOUNT_STATUS,
        COALESCE(REGISTRATION_DATE, '1900-01-01'::DATE) AS REGISTRATION_DATE,
        CASE 
            WHEN COALESCE(PLAN_TYPE, 'Unknown') = 'Enterprise' THEN 'Enterprise'
            WHEN COALESCE(PLAN_TYPE, 'Unknown') = 'Pro' THEN 'Professional'
            WHEN COALESCE(PLAN_TYPE, 'Unknown') = 'Basic' THEN 'Small Business'
            ELSE 'Individual'
        END AS USER_SEGMENT,
        CURRENT_DATE() AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM user_source
)

SELECT * FROM user_transformed
