{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, CREATED_AT, UPDATED_AT) VALUES (GENERATE_UUID(), 'go_dim_user_transformation', 'SI_USERS', 'GO_DIM_USER', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIME = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'COMPLETED', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), UPDATED_AT = CURRENT_TIMESTAMP() WHERE PROCESS_NAME = 'go_dim_user_transformation' AND PROCESS_STATUS = 'STARTED'"
) }}

-- User Dimension Table
WITH user_base AS (
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
        VALIDATION_STATUS
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
        AND DATA_QUALITY_SCORE >= 80
),

user_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY USER_ID, LOAD_TIMESTAMP) AS USER_DIM_ID,
        USER_ID,
        COALESCE(TRIM(UPPER(USER_NAME)), 'Unknown User') AS USER_NAME,
        -- Extract email domain
        CASE 
            WHEN EMAIL IS NOT NULL AND EMAIL LIKE '%@%' THEN 
                LOWER(TRIM(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1)))
            ELSE 'Unknown Domain'
        END AS EMAIL_DOMAIN,
        COALESCE(TRIM(INITCAP(COMPANY)), 'Unknown Company') AS COMPANY,
        UPPER(TRIM(PLAN_TYPE)) AS PLAN_TYPE,
        -- Standardize plan category
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Professional'
            WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Other'
        END AS PLAN_CATEGORY,
        LOAD_DATE AS REGISTRATION_DATE,
        'Active' AS USER_STATUS,
        'North America' AS GEOGRAPHIC_REGION,
        'Technology' AS INDUSTRY_SECTOR,
        'End User' AS USER_ROLE,
        'Standard' AS ACCOUNT_TYPE,
        'UTC' AS TIME_ZONE,
        'English' AS LANGUAGE_PREFERENCE,
        LOAD_DATE AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM user_base
)

SELECT * FROM user_enriched
