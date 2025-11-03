{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ config(
    pre_hook="INSERT INTO {{ ref('audit_log') }} (source_table, process_start_time, status) VALUES ('{{ this.name }}', CURRENT_TIMESTAMP(), 'STARTED')"
) }}
{% endif %}

-- Main transformation
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
    FROM {{ ref('bz_users') }}
    WHERE USER_ID IS NOT NULL
),

cleaned_data AS (
    SELECT 
        USER_ID,
        TRIM(UPPER(USER_NAME)) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        CASE 
            WHEN PLAN_TYPE = 'Free' THEN 'Active'
            WHEN PLAN_TYPE IN ('Basic', 'Pro', 'Enterprise') THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality score calculation
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                 AND USER_NAME IS NOT NULL 
                 AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN 1.00
            ELSE 0.75
        END AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE EMAIL IS NOT NULL 
      AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
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
    LOAD_DATE,
    UPDATE_DATE,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM deduplicated

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ config(
    post_hook="UPDATE {{ ref('audit_log') }} SET process_end_time = CURRENT_TIMESTAMP(), status = 'COMPLETED', rows_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE source_table = '{{ this.name }}' AND status = 'STARTED'"
) }}
{% endif %}
