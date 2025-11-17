{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_START_TIME, PROCESSED_BY, CREATED_AT) SELECT 'SI_USERS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, PROCESS_END_TIME, PROCESSED_BY, RECORDS_PROCESSED, UPDATED_AT) SELECT 'SI_USERS', 'COMPLETED', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Users table
-- Applies data quality checks and standardization

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
    FROM {{ source('bronze', 'BZ_USERS') }}
    WHERE USER_ID IS NOT NULL  -- Remove null user IDs
),

data_quality_checks AS (
    SELECT 
        *,
        -- Email format validation
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 1
            ELSE 0
        END AS email_valid,
        
        -- Plan type standardization
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 1
            ELSE 0
        END AS plan_type_valid,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_users
),

cleansed_users AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN UPPER(PLAN_TYPE)
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality score calculation
        CASE 
            WHEN email_valid = 1 AND plan_type_valid = 1 THEN 100
            WHEN email_valid = 1 OR plan_type_valid = 1 THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN email_valid = 1 AND plan_type_valid = 1 THEN 'PASSED'
            WHEN email_valid = 1 OR plan_type_valid = 1 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM data_quality_checks
    WHERE rn = 1  -- Keep only the latest record for each user
)

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
    CREATED_AT,
    UPDATED_AT
FROM cleansed_users
