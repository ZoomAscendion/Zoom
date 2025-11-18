{{ config(
    materialized='table',
    tags=['silver', 'users']
) }}

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
    FROM {{ ref('bz_users') }}
),

data_quality_checks AS (
    SELECT 
        USER_ID,
        TRIM(COALESCE(USER_NAME, 'UNKNOWN')) AS USER_NAME,
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
            THEN LOWER(TRIM(EMAIL))
            ELSE NULL
        END AS EMAIL,
        TRIM(COALESCE(COMPANY, 'UNKNOWN')) AS COMPANY,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'FREE'
        END AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        CASE 
            WHEN USER_ID IS NULL THEN 0
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 30
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 60
            WHEN PLAN_TYPE IS NULL OR UPPER(TRIM(PLAN_TYPE)) NOT IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 80
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN USER_ID IS NULL THEN 'FAILED'
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'FAILED'
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'WARNING'
            WHEN PLAN_TYPE IS NULL OR UPPER(TRIM(PLAN_TYPE)) NOT IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_users
    WHERE USER_ID IS NOT NULL
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM data_quality_checks
WHERE rn = 1
