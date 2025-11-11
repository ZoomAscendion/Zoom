{{
  config(
    materialized='table',
    cluster_by=['USER_KEY'],
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, LOAD_DATE, SOURCE_SYSTEM) SELECT '{{ invocation_id }}', 'DIM_USER_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_USERS', 'GO_DIM_USER', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_audit_log'",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIMESTAMP, CURRENT_TIMESTAMP()) WHERE AUDIT_LOG_ID = '{{ invocation_id }}' AND '{{ this.name }}' != 'go_audit_log'"
  )
}}

-- User Dimension Transformation
WITH user_data AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['USER_ID']) }} AS USER_KEY,
        ROW_NUMBER() OVER (ORDER BY USER_ID) AS USER_DIM_ID,
        USER_ID,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown'))) AS USER_NAME,
        CASE 
            WHEN EMAIL IS NOT NULL AND POSITION('@' IN EMAIL) > 0 
            THEN UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1))
            ELSE 'Unknown'
        END AS EMAIL_DOMAIN,
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown'))) AS COMPANY,
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, '')) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(COALESCE(PLAN_TYPE, '')) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(COALESCE(PLAN_TYPE, '')) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, '')) = 'FREE' THEN 'Free'
            WHEN UPPER(COALESCE(PLAN_TYPE, '')) IN ('BASIC', 'PRO', 'PROFESSIONAL', 'BUSINESS', 'ENTERPRISE') THEN 'Paid'
            ELSE 'Unknown'
        END AS PLAN_CATEGORY,
        COALESCE(LOAD_DATE, CURRENT_DATE()) AS REGISTRATION_DATE,
        CASE 
            WHEN COALESCE(VALIDATION_STATUS, '') = 'PASSED' THEN 'Active'
            ELSE 'Inactive'
        END AS USER_STATUS,
        'Unknown' AS GEOGRAPHIC_REGION,
        'Unknown' AS INDUSTRY_SECTOR,
        'Unknown' AS USER_ROLE,
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, '')) = 'FREE' THEN 'Individual'
            ELSE 'Business'
        END AS ACCOUNT_TYPE,
        'English' AS LANGUAGE_PREFERENCE,
        CURRENT_DATE() AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'SILVER_LAYER') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_users') }}
    WHERE COALESCE(VALIDATION_STATUS, '') = 'PASSED'
)

SELECT * FROM user_data
