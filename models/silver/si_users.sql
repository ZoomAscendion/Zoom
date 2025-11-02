{{
  config(
    materialized='table'
  )
}}

WITH deduplicated_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
    FROM {{ source('bronze', 'BZ_USERS') }}
    WHERE USER_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data Quality Score Calculation
        (
            CASE WHEN USER_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN USER_NAME IS NOT NULL AND TRIM(USER_NAME) != '' THEN 0.2 ELSE 0 END +
            CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 0.3 ELSE 0 END +
            CASE WHEN COMPANY IS NOT NULL AND TRIM(COMPANY) != '' THEN 0.15 ELSE 0 END +
            CASE WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 0.15 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        -- Email validation
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
            THEN EMAIL 
            ELSE NULL 
        END AS VALIDATED_EMAIL,
        -- Plan type standardization
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN INITCAP(PLAN_TYPE)
            ELSE 'Free'
        END AS STANDARDIZED_PLAN_TYPE
    FROM deduplicated_users
    WHERE rn = 1
)

SELECT 
    USER_ID,
    USER_NAME,
    VALIDATED_EMAIL AS EMAIL,
    COMPANY,
    STANDARDIZED_PLAN_TYPE AS PLAN_TYPE,
    LOAD_TIMESTAMP::DATE AS REGISTRATION_DATE,
    LOAD_TIMESTAMP::DATE AS LAST_LOGIN_DATE,
    'Active' AS ACCOUNT_STATUS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    ROUND(DATA_QUALITY_SCORE, 2) AS DATA_QUALITY_SCORE,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE
FROM data_quality_checks
WHERE DATA_QUALITY_SCORE >= 0.5
    AND USER_ID IS NOT NULL
    AND VALIDATED_EMAIL IS NOT NULL
