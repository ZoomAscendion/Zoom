{{ config(
    materialized='table',
    tags=['dimension', 'gold']
) }}

-- User Dimension Transformation
-- Transforms Silver layer user data into Gold dimension with enhanced attributes

WITH source_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        LOAD_DATE,
        UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

transformed_users AS (
    SELECT 
        MD5(USER_ID) as USER_KEY,
        USER_ID,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown'))) as USER_NAME,
        UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1)) as EMAIL_DOMAIN,
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown'))) as COMPANY,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Unknown'
        END as PLAN_TYPE,
        CASE 
            WHEN UPPER(PLAN_TYPE) = 'FREE' THEN 'Free'
            ELSE 'Paid'
        END as PLAN_CATEGORY,
        LOAD_DATE as REGISTRATION_DATE,
        CASE 
            WHEN VALIDATION_STATUS = 'PASSED' THEN 'Active'
            ELSE 'Inactive'
        END as USER_STATUS,
        'Unknown' as GEOGRAPHIC_REGION,
        'Unknown' as INDUSTRY_SECTOR,
        'Standard User' as USER_ROLE,
        CASE 
            WHEN UPPER(PLAN_TYPE) = 'FREE' THEN 'Individual'
            ELSE 'Business'
        END as ACCOUNT_TYPE,
        'English' as LANGUAGE_PREFERENCE,
        CURRENT_DATE() as EFFECTIVE_START_DATE,
        '9999-12-31'::DATE as EFFECTIVE_END_DATE,
        TRUE as IS_CURRENT_RECORD,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_users
    WHERE rn = 1
)

SELECT * FROM transformed_users
