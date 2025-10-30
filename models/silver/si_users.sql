{{ config(
    materialized='incremental',
    unique_key='user_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Users
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

-- Data Quality Checks and Cleansing
cleansed_users AS (
    SELECT 
        TRIM(USER_ID) as USER_ID,
        INITCAP(TRIM(USER_NAME)) as USER_NAME,
        LOWER(TRIM(EMAIL)) as EMAIL,
        INITCAP(TRIM(COMPANY)) as COMPANY,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(PLAN_TYPE)
            ELSE 'UNKNOWN'
        END as PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) as REGISTRATION_DATE,
        DATE(UPDATE_TIMESTAMP) as LAST_LOGIN_DATE,
        CASE 
            WHEN PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 'Active'
            ELSE 'Inactive'
        END as ACCOUNT_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_users
    WHERE EMAIL IS NOT NULL 
        AND EMAIL REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
        AND USER_NAME IS NOT NULL
        AND TRIM(USER_NAME) != ''
),

-- Remove duplicates using ROW_NUMBER
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM cleansed_users
),

-- Calculate data quality score
final_users AS (
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
        -- Calculate data quality score based on completeness
        ROUND(
            (CASE WHEN USER_NAME IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN EMAIL IS NOT NULL THEN 0.3 ELSE 0 END +
             CASE WHEN COMPANY IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN PLAN_TYPE != 'UNKNOWN' THEN 0.2 ELSE 0 END +
             CASE WHEN REGISTRATION_DATE IS NOT NULL THEN 0.1 ELSE 0 END), 2
        ) as DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduped_users
    WHERE rn = 1
)

SELECT * FROM final_users

{% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
