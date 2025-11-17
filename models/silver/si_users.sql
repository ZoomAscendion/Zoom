{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT '{{ this.name }}', 'SI_USERS', 'STARTED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT '{{ this.name }}', 'SI_USERS', 'COMPLETED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Users Table
-- Transforms and cleanses user data from Bronze layer
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
),

cleansed_users AS (
    SELECT 
        USER_ID,
        TRIM(UPPER(USER_NAME)) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                 AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN 100
            WHEN EMAIL IS NOT NULL AND PLAN_TYPE IS NOT NULL THEN 75
            WHEN EMAIL IS NOT NULL OR PLAN_TYPE IS NOT NULL THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                 AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN 'PASSED'
            WHEN EMAIL IS NULL OR PLAN_TYPE IS NULL THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM bronze_users
),

deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM cleansed_users
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
FROM deduped_users
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
