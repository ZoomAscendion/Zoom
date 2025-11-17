{{ config(
    materialized='table'
) }}

-- Silver Layer Users Table
-- Purpose: Clean and standardized user profile and subscription information
-- Source: Bronze.BZ_USERS

WITH source_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_USERS') }}
),

-- Data Quality and Cleansing
cleansed_data AS (
    SELECT 
        -- Primary identifiers
        COALESCE(TRIM(USER_ID), 'UNKNOWN_USER_' || ROW_NUMBER() OVER (ORDER BY LOAD_TIMESTAMP)) AS USER_ID,
        
        -- User information with cleansing
        CASE 
            WHEN TRIM(USER_NAME) IS NULL OR TRIM(USER_NAME) = '' THEN 'UNKNOWN_USER'
            ELSE TRIM(USER_NAME)
        END AS USER_NAME,
        
        -- Email validation and cleansing
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN 'no-email@unknown.com'
            WHEN NOT REGEXP_LIKE(TRIM(EMAIL), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'invalid-email@unknown.com'
            ELSE LOWER(TRIM(EMAIL))
        END AS EMAIL,
        
        -- Company standardization
        CASE 
            WHEN TRIM(COMPANY) IS NULL OR TRIM(COMPANY) = '' THEN 'UNKNOWN_COMPANY'
            ELSE TRIM(COMPANY)
        END AS COMPANY,
        
        -- Plan type standardization
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE') THEN UPPER(TRIM(PLAN_TYPE))
            WHEN TRIM(PLAN_TYPE) IS NULL OR TRIM(PLAN_TYPE) = '' THEN 'FREE'
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        
        -- Metadata columns
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) AS LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) AS UPDATE_TIMESTAMP,
        COALESCE(TRIM(SOURCE_SYSTEM), 'UNKNOWN') AS SOURCE_SYSTEM,
        
        -- Silver layer specific columns
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        
        -- Data quality scoring
        CASE 
            WHEN USER_ID IS NOT NULL 
                 AND EMAIL IS NOT NULL 
                 AND REGEXP_LIKE(TRIM(EMAIL), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                 AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE') THEN 100
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL THEN 80
            WHEN USER_ID IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USER_ID IS NULL THEN 'FAILED'
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(TRIM(EMAIL), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM source_data
    WHERE USER_ID IS NOT NULL
),

-- Final deduplication
final_data AS (
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
    FROM cleansed_data
    WHERE rn = 1
)

SELECT * FROM final_data
