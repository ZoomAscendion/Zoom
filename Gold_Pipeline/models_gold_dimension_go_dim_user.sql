/*
  Model: go_dim_user
  Author: Data Engineering Team
  Created: 2024-12-19
  Description: User dimension table containing user profile and subscription information
  
  This model transforms Silver layer user data into a comprehensive user dimension
  with unique records per user, incorporating SCD Type 2 logic to track historical
  changes while ensuring current active records are unique.
  
  Dependencies: go_process_audit
  Source: silver.SI_USERS
  Materialization: Table
  Clustering: USER_KEY, IS_CURRENT_RECORD
  Uniqueness: Composite uniqueness based on USER_ID + IS_CURRENT_RECORD flag
*/

{{ config(
    materialized='table',
    cluster_by=['USER_KEY', 'IS_CURRENT_RECORD'],
    tags=['dimension', 'gold_layer', 'user', 'scd_type2'],
    on_schema_change='fail'
) }}

-- Transform Silver layer user data into Gold dimension
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
    FROM {{ source('silver', 'SI_USERS') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND USER_ID IS NOT NULL
      AND TRIM(USER_ID) != ''
),

user_transformations AS (
    SELECT 
        -- Generate unique user key
        CONCAT('USR_', USER_ID) AS USER_KEY,
        
        -- Original user data
        USER_ID,
        UPPER(TRIM(COALESCE(USER_NAME, 'UNKNOWN'))) AS USER_NAME,
        
        -- Extract email domain for analysis
        CASE 
            WHEN EMAIL IS NOT NULL AND CONTAINS(EMAIL, '@') 
            THEN UPPER(SPLIT_PART(EMAIL, '@', 2))
            ELSE 'UNKNOWN'
        END AS EMAIL_DOMAIN,
        
        -- Standardize company name
        UPPER(TRIM(COALESCE(COMPANY, 'UNKNOWN'))) AS COMPANY,
        
        -- Standardize plan type
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'BASIC'
            WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'PRO'
            WHEN UPPER(PLAN_TYPE) IN ('BUSINESS') THEN 'BUSINESS'
            WHEN UPPER(PLAN_TYPE) IN ('ENTERPRISE') THEN 'ENTERPRISE'
            ELSE 'OTHER'
        END AS PLAN_TYPE,
        
        -- Derive plan category
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE') THEN 'FREE_TIER'
            WHEN UPPER(PLAN_TYPE) IN ('BASIC', 'PRO', 'PROFESSIONAL') THEN 'PAID_INDIVIDUAL'
            WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'PAID_ORGANIZATION'
            ELSE 'UNKNOWN'
        END AS PLAN_CATEGORY,
        
        -- Registration date (use load timestamp as proxy)
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        
        -- Default user status
        'ACTIVE' AS USER_STATUS,
        
        -- Geographic region (to be enhanced with actual data)
        CASE 
            WHEN EMAIL IS NOT NULL AND CONTAINS(EMAIL, '@') THEN
                CASE 
                    WHEN UPPER(SPLIT_PART(EMAIL, '@', 2)) LIKE '%.COM' THEN 'NORTH_AMERICA'
                    WHEN UPPER(SPLIT_PART(EMAIL, '@', 2)) LIKE '%.UK' OR UPPER(SPLIT_PART(EMAIL, '@', 2)) LIKE '%.EU' THEN 'EUROPE'
                    WHEN UPPER(SPLIT_PART(EMAIL, '@', 2)) LIKE '%.JP' OR UPPER(SPLIT_PART(EMAIL, '@', 2)) LIKE '%.CN' THEN 'ASIA_PACIFIC'
                    ELSE 'UNKNOWN'
                END
            ELSE 'UNKNOWN'
        END AS GEOGRAPHIC_REGION,
        
        -- Industry sector (to be enhanced with actual data)
        CASE 
            WHEN UPPER(COMPANY) LIKE '%TECH%' OR UPPER(COMPANY) LIKE '%SOFTWARE%' THEN 'TECHNOLOGY'
            WHEN UPPER(COMPANY) LIKE '%BANK%' OR UPPER(COMPANY) LIKE '%FINANCIAL%' THEN 'FINANCIAL_SERVICES'
            WHEN UPPER(COMPANY) LIKE '%HEALTH%' OR UPPER(COMPANY) LIKE '%MEDICAL%' THEN 'HEALTHCARE'
            WHEN UPPER(COMPANY) LIKE '%EDU%' OR UPPER(COMPANY) LIKE '%SCHOOL%' OR UPPER(COMPANY) LIKE '%UNIVERSITY%' THEN 'EDUCATION'
            ELSE 'OTHER'
        END AS INDUSTRY_SECTOR,
        
        -- User role (default)
        'STANDARD_USER' AS USER_ROLE,
        
        -- Account type
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'ORGANIZATION'
            ELSE 'INDIVIDUAL'
        END AS ACCOUNT_TYPE,
        
        -- Language preference (default)
        'ENGLISH' AS LANGUAGE_PREFERENCE,
        
        -- SCD Type 2 fields
        DATE(LOAD_TIMESTAMP) AS EFFECTIVE_START_DATE,
        DATE('9999-12-31') AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        
        -- Metadata
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        
        -- Row number for deduplication (keep most recent)
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
        
    FROM source_users
),

deduped_users AS (
    SELECT *
    FROM user_transformations
    WHERE rn = 1
)

SELECT 
    -- Primary dimension key
    USER_KEY,
    
    -- Auto-increment surrogate key (will be populated by Snowflake)
    NULL AS USER_DIM_ID,
    
    -- User identification
    USER_ID,
    USER_NAME,
    EMAIL_DOMAIN,
    COMPANY,
    
    -- Plan information
    PLAN_TYPE,
    PLAN_CATEGORY,
    
    -- User attributes
    REGISTRATION_DATE,
    USER_STATUS,
    GEOGRAPHIC_REGION,
    INDUSTRY_SECTOR,
    USER_ROLE,
    ACCOUNT_TYPE,
    LANGUAGE_PREFERENCE,
    
    -- SCD Type 2 fields
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    IS_CURRENT_RECORD,
    
    -- Standard metadata columns
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    '{{ var("source_system") }}' AS SOURCE_SYSTEM
    
FROM deduped_users
ORDER BY USER_KEY