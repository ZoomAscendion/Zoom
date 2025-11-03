-- models/silver/si_users.sql
{{ config(
    materialized='table'
) }}

-- Pre-hook to log process start
{% if this.name != 'audit_log' %}
{{ log('Starting transformation for si_users') }}
{% endif %}

-- Main transformation using CTEs
WITH source_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM DB_POC_ZOOM.BRONZE.BZ_USERS
    WHERE USER_ID IS NOT NULL
),

cleaned_data AS (
    -- Data quality checks and transformations
    SELECT 
        USER_ID,
        TRIM(UPPER(COALESCE(USER_NAME, 'UNKNOWN'))) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(INITCAP(COALESCE(COMPANY, 'Unknown'))) AS COMPANY,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(PLAN_TYPE)
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        CASE 
            WHEN PLAN_TYPE IS NOT NULL THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality score calculation
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND USER_NAME IS NOT NULL
            THEN 1.0
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL
            THEN 0.8
            WHEN USER_ID IS NOT NULL
            THEN 0.6
            ELSE 0.0
        END AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE EMAIL IS NOT NULL 
        AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    LOAD_DATE,
    UPDATE_DATE
FROM deduplication
