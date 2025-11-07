{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('GO_DIM_USER_LOAD', 'SI_USERS', 'GO_DIM_USER', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, PROCESS_STATUS, RECORDS_PROCESSED, RECORDS_SUCCESS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('GO_DIM_USER_LOAD', 'SI_USERS', 'GO_DIM_USER', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')"
) }}

-- Gold Layer User Dimension
-- Dimension table containing user profile and subscription information for user analysis

WITH user_base AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        VALIDATION_STATUS,
        DATA_QUALITY_SCORE
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
        AND DATA_QUALITY_SCORE >= 80
),

user_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY USER_ID, LOAD_DATE) AS USER_DIM_ID,
        COALESCE(TRIM(UPPER(USER_NAME)), 'Unknown User') AS USER_NAME,
        CASE 
            WHEN EMAIL IS NOT NULL AND EMAIL LIKE '%@%' 
            THEN LOWER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1))
            ELSE 'Unknown Domain'
        END AS EMAIL_DOMAIN,
        COALESCE(TRIM(INITCAP(COMPANY)), 'Unknown Company') AS COMPANY,
        COALESCE(UPPER(TRIM(PLAN_TYPE)), 'Unknown Plan') AS PLAN_TYPE,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS PLAN_CATEGORY,
        LOAD_DATE AS REGISTRATION_DATE,
        'Active' AS USER_STATUS, -- Simplified for initial load
        'North America' AS GEOGRAPHIC_REGION, -- Default value
        'Technology' AS INDUSTRY_SECTOR, -- Default value
        'Standard User' AS USER_ROLE, -- Default value
        'Individual' AS ACCOUNT_TYPE, -- Default value
        'UTC' AS TIME_ZONE, -- Default value
        'English' AS LANGUAGE_PREFERENCE, -- Default value
        LOAD_DATE AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM user_base
)

SELECT * FROM user_enriched
