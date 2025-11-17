{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('si_audit_log') }} (
            EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, 
            SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP
        )
        VALUES (
            '{{ invocation_id }}', 
            'si_users', 
            CURRENT_TIMESTAMP(), 
            'RUNNING', 
            'BRONZE.BZ_USERS', 
            'SILVER.SI_USERS', 
            'DBT_SILVER_PIPELINE', 
            CURRENT_TIMESTAMP()
        )",
    post_hook="
        UPDATE {{ ref('si_audit_log') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }})
        WHERE EXECUTION_ID = '{{ invocation_id }}' 
        AND TARGET_TABLE = 'SILVER.SI_USERS'"
) }}

-- Silver layer users table with data quality checks and cleansing
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
    WHERE USER_ID IS NOT NULL  -- Remove null user IDs
),

cleansed_users AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,  -- Standardize email format
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN UPPER(PLAN_TYPE)
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,  -- Standardize plan types
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality scoring
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
                 AND PLAN_TYPE != 'UNKNOWN' THEN 100
            WHEN EMAIL IS NOT NULL AND PLAN_TYPE != 'UNKNOWN' THEN 80
            WHEN EMAIL IS NOT NULL OR PLAN_TYPE != 'UNKNOWN' THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
                 AND PLAN_TYPE != 'UNKNOWN' THEN 'PASSED'
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_users
    WHERE EMAIL IS NOT NULL  -- Remove records with null emails
      AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')  -- Valid email format only
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
    VALIDATION_STATUS
FROM cleansed_users
WHERE rn = 1  -- Remove duplicates, keep latest record
