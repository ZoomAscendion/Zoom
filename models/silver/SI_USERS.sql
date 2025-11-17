{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_START_TIME, EXECUTED_BY, LOAD_TIMESTAMP) SELECT 'SI_USERS', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT 'SI_USERS', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Users Table
-- Purpose: Clean and standardized user profile and subscription information
-- Transformation: Bronze BZ_USERS -> Silver SI_USERS

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
    WHERE USER_ID IS NOT NULL
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
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 1
            ELSE 0
        END AS plan_type_valid,
        
        -- Calculate data quality score
        CASE 
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL AND PLAN_TYPE IS NOT NULL THEN
                CASE 
                    WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                         AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 100
                    WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 80
                    WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 70
                    ELSE 50
                END
            ELSE 0
        END AS data_quality_score
    FROM bronze_users
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

cleaned_users AS (
    SELECT 
        USER_ID,
        COALESCE(TRIM(USER_NAME), 'Unknown User') AS USER_NAME,
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
            THEN LOWER(TRIM(EMAIL))
            ELSE NULL
        END AS EMAIL,
        COALESCE(TRIM(COMPANY), 'Unknown Company') AS COMPANY,
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Basic'
        END AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 80 THEN 'PASSED'
            WHEN data_quality_score >= 50 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
      AND USER_ID IS NOT NULL
)

SELECT * FROM cleaned_users
