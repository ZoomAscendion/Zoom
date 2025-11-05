{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Bronze to Silver transformation for Users
-- Implements data quality checks and standardization

WITH bronze_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_users') }}
    WHERE USER_ID IS NOT NULL
      AND TRIM(USER_ID) != ''
),

data_quality_checks AS (
    SELECT 
        *,
        -- Email validation
        CASE 
            WHEN EMAIL IS NULL OR EMAIL NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' 
            THEN 'INVALID_EMAIL'
            ELSE 'VALID'
        END AS email_validation,
        
        -- Plan type standardization
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'UNKNOWN'
        END AS standardized_plan_type
    FROM bronze_users
),

valid_records AS (
    SELECT 
        USER_ID,
        TRIM(UPPER(USER_NAME)) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        standardized_plan_type AS PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
    WHERE email_validation = 'VALID'
      AND USER_NAME IS NOT NULL
      AND TRIM(USER_NAME) != ''
)

SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM valid_records
WHERE rn = 1
