{{ config(
    materialized='incremental',
    unique_key='user_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Users data with data quality validations
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
    
    {% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

-- Data quality validations and cleansing
cleansed_users AS (
    SELECT 
        TRIM(USER_ID) AS user_id,
        INITCAP(TRIM(USER_NAME)) AS user_name,
        LOWER(TRIM(EMAIL)) AS email,
        INITCAP(TRIM(COMPANY)) AS company,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'FREE'
        END AS plan_type,
        DATE(LOAD_TIMESTAMP) AS registration_date,
        DATE(UPDATE_TIMESTAMP) AS last_login_date,
        CASE 
            WHEN UPDATE_TIMESTAMP >= CURRENT_DATE() - INTERVAL '30 DAYS' THEN 'Active'
            WHEN UPDATE_TIMESTAMP >= CURRENT_DATE() - INTERVAL '90 DAYS' THEN 'Inactive'
            ELSE 'Suspended'
        END AS account_status,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        -- Data quality score calculation
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IS NOT NULL
            THEN 1.00
            WHEN USER_ID IS NOT NULL AND USER_NAME IS NOT NULL AND EMAIL IS NOT NULL
            THEN 0.80
            WHEN USER_ID IS NOT NULL AND USER_NAME IS NOT NULL
            THEN 0.60
            WHEN USER_ID IS NOT NULL
            THEN 0.40
            ELSE 0.00
        END AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_users
    WHERE USER_ID IS NOT NULL
        AND TRIM(USER_ID) != ''
),

-- Deduplication using ROW_NUMBER to keep latest record
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM cleansed_users
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
WHERE row_num = 1
    AND data_quality_score >= 0.40  -- Minimum quality threshold
