{{ config(
    materialized='table',
    tags=['silver', 'users']
) }}

WITH source_users AS (
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

validated_users AS (
    SELECT
        USER_ID,
        INITCAP(TRIM(USER_NAME)) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        INITCAP(TRIM(COMPANY)) AS COMPANY,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'BASIC'
        END AS PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        CASE
            WHEN UPDATE_TIMESTAMP >= DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 'Active'
            WHEN UPDATE_TIMESTAMP >= DATEADD('day', -90, CURRENT_TIMESTAMP()) THEN 'Inactive'
            ELSE 'Suspended'
        END AS ACCOUNT_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_users
    WHERE EMAIL IS NOT NULL
      AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
),

quality_scored_users AS (
    SELECT
        *,
        (
            CASE WHEN USER_NAME IS NOT NULL AND TRIM(USER_NAME) != '' THEN 0.20 ELSE 0 END +
            CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0.25 ELSE 0 END +
            CASE WHEN COMPANY IS NOT NULL AND TRIM(COMPANY) != '' THEN 0.15 ELSE 0 END +
            CASE WHEN PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 0.20 ELSE 0 END +
            CASE WHEN REGISTRATION_DATE IS NOT NULL AND REGISTRATION_DATE <= CURRENT_DATE() THEN 0.20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE
    FROM validated_users
),

deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS row_num
    FROM quality_scored_users
)

SELECT
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    REGISTRATION_DATE,
    LAST_LOGIN_DATE,
    ACCOUNT_STATUS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_users
WHERE row_num = 1
  AND DATA_QUALITY_SCORE >= 0.60
