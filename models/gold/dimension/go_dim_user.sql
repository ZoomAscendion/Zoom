{{
  config(
    materialized='table',
    cluster_by=['USER_DIM_ID', 'EFFECTIVE_START_DATE'],
    tags=['dimension', 'gold']
  )
}}

-- User Dimension Table
-- Transforms Silver layer user data into Gold layer dimension with enhanced attributes

WITH source_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM {{ source('silver', 'si_users') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

transformed_data AS (
    SELECT 
        -- Surrogate Keys
        {{ dbt_utils.generate_surrogate_key(['USER_ID']) }} AS USER_DIM_ID,
        USER_ID,
        
        -- Standardized User Information
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown User'))) AS USER_NAME,
        UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) AS EMAIL_DOMAIN,
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown Company'))) AS COMPANY,
        
        -- Plan Type Standardization
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, 'FREE')) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(COALESCE(PLAN_TYPE, 'FREE')) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(COALESCE(PLAN_TYPE, 'FREE')) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        
        -- Plan Category
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, 'FREE')) = 'FREE' THEN 'Free'
            ELSE 'Paid'
        END AS PLAN_CATEGORY,
        
        -- Registration Date
        COALESCE(LOAD_DATE, CURRENT_DATE()) AS REGISTRATION_DATE,
        
        -- User Status
        CASE 
            WHEN COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED' THEN 'Active'
            ELSE 'Inactive'
        END AS USER_STATUS,
        
        -- Geographic Region (derived from email domain)
        CASE 
            WHEN UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.COM' THEN 'North America'
            WHEN UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.UK' 
                 OR UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) LIKE '%.EU' THEN 'Europe'
            ELSE 'Unknown'
        END AS GEOGRAPHIC_REGION,
        
        -- Industry Sector (derived from company name)
        CASE 
            WHEN UPPER(COALESCE(COMPANY, '')) LIKE '%TECH%' OR UPPER(COALESCE(COMPANY, '')) LIKE '%SOFTWARE%' THEN 'Technology'
            WHEN UPPER(COALESCE(COMPANY, '')) LIKE '%BANK%' OR UPPER(COALESCE(COMPANY, '')) LIKE '%FINANCE%' THEN 'Financial Services'
            ELSE 'Unknown'
        END AS INDUSTRY_SECTOR,
        
        -- User Role
        'Standard User' AS USER_ROLE,
        
        -- Account Type
        CASE 
            WHEN UPPER(COALESCE(PLAN_TYPE, 'FREE')) = 'FREE' THEN 'Individual'
            ELSE 'Business'
        END AS ACCOUNT_TYPE,
        
        -- Language Preference
        'English' AS LANGUAGE_PREFERENCE,
        
        -- SCD Type 2 Fields
        CURRENT_DATE() AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        
        -- Metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_data
)

SELECT * FROM transformed_data
