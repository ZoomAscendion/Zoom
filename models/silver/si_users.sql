{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Users transformation with data quality checks
WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
    WHERE USER_ID IS NOT NULL
      AND TRIM(USER_ID) != ''
      AND EMAIL IS NOT NULL
      AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
      AND USER_NAME IS NOT NULL
      AND LENGTH(TRIM(USER_NAME)) > 0
      AND LENGTH(USER_NAME) <= 100
),

deduped_users AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_users
),

final_users AS (
    SELECT 
        USER_ID,
        TRIM(UPPER(USER_NAME)) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'EDUCATION') 
            THEN UPPER(PLAN_TYPE)
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM deduped_users
    WHERE rn = 1
)

SELECT * FROM final_users
