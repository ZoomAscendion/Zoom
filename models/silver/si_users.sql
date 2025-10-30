{{
  config(
    materialized='incremental',
    unique_key='user_id',
    on_schema_change='sync_all_columns'
  )
}}

WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
    WHERE USER_ID IS NOT NULL
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleaned_users AS (
    SELECT 
        TRIM(USER_ID) AS user_id,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown'))) AS user_name,
        LOWER(TRIM(EMAIL)) AS email,
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown'))) AS company,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'UNKNOWN'
        END AS plan_type,
        DATE(LOAD_TIMESTAMP) AS registration_date,
        DATE(UPDATE_TIMESTAMP) AS last_login_date,
        CASE 
            WHEN UPDATE_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '30 DAYS' THEN 'ACTIVE'
            WHEN UPDATE_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '90 DAYS' THEN 'INACTIVE'
            ELSE 'SUSPENDED'
        END AS account_status,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        {{ calculate_data_quality_score() }} AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_users
),

deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY update_timestamp DESC) AS rn
    FROM cleaned_users
)

SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    registration_date,
    last_login_date,
    account_status,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM deduped_users
WHERE rn = 1
    AND (email LIKE '%@%' OR email IS NULL)
    AND user_name IS NOT NULL
