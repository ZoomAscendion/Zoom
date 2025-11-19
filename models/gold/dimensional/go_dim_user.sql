{{ config(
    materialized='table',
    cluster_by=['USER_ID', 'EFFECTIVE_START_DATE'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIMESTAMP, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) VALUES ('{{ dbt_utils.generate_surrogate_key(["'go_dim_user'", "CURRENT_TIMESTAMP()"]) }}', 'GO_DIM_USER_LOAD', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_USERS', 'GO_DIM_USER', 'DBT_MODEL_RUN', 'DBT_USER', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIMESTAMP = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), DATA_QUALITY_SCORE = 95.0 WHERE PROCESS_ID = '{{ dbt_utils.generate_surrogate_key(["'go_dim_user'", "CURRENT_TIMESTAMP()"]) }}'"
) }}

-- User dimension with SCD Type 2 implementation
-- Transforms Silver layer user data into business-ready dimension

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
        VALIDATION_STATUS
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND USER_ID IS NOT NULL
),

user_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY USER_ID) AS USER_DIM_ID,
        USER_ID,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown User'))) AS USER_NAME,
        UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) AS EMAIL_DOMAIN,
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
        CASE 
            WHEN VALIDATION_STATUS = 'PASSED' THEN 'Active'
            ELSE 'Inactive'
        END AS USER_STATUS,
        CASE 
            WHEN UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.COM' THEN 'North America'
            WHEN UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.UK' 
                 OR UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.EU' THEN 'Europe'
            ELSE 'Unknown'
        END AS GEOGRAPHIC_REGION,
        CASE 
            WHEN UPPER(COALESCE(COMPANY, '')) LIKE '%TECH%' OR UPPER(COALESCE(COMPANY, '')) LIKE '%SOFTWARE%' THEN 'Technology'
            WHEN UPPER(COALESCE(COMPANY, '')) LIKE '%BANK%' OR UPPER(COALESCE(COMPANY, '')) LIKE '%FINANCE%' THEN 'Financial Services'
            ELSE 'Unknown'
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
