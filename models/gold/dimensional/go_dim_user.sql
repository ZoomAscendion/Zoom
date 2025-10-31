{{ config(
    materialized='table',
    cluster_by=['USER_BUSINESS_KEY', 'IS_CURRENT']
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
        DATA_QUALITY_SCORE
    FROM {{ source('silver', 'si_users') }}
    WHERE DATA_QUALITY_SCORE >= 0.8
),

user_transformed AS (
    SELECT 
        'DIM_USER_' || USER_ID || '_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS') AS DIM_USER_ID,
        USER_ID AS USER_BUSINESS_KEY,
        INITCAP(TRIM(USER_NAME)) AS USER_NAME,
        UPPER(SPLIT_PART(EMAIL, '@', 2)) AS EMAIL_DOMAIN,
        INITCAP(TRIM(COMPANY)) AS COMPANY_NAME,
        UPPER(PLAN_TYPE) AS PLAN_TYPE,
        UPPER(ACCOUNT_STATUS) AS ACCOUNT_STATUS,
        REGISTRATION_DATE,
        CASE 
            WHEN PLAN_TYPE = 'Enterprise' THEN 'Enterprise'
            WHEN PLAN_TYPE = 'Pro' THEN 'Professional'
            WHEN PLAN_TYPE = 'Basic' THEN 'Small Business'
            ELSE 'Individual'
        END AS USER_SEGMENT,
        CURRENT_DATE() AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM user_source
)

SELECT * FROM user_transformed
