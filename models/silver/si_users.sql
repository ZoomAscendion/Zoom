{{
    config(
        materialized='incremental',
        unique_key='user_id',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Users Transformation
-- Source: Bronze.BZ_USERS
-- Target: Silver.SI_USERS

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
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Data Quality and Transformation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN USER_ID IS NULL THEN 0.0
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0.3
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 0.5
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 0.7
            ELSE 1.0
        END AS data_quality_score,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_users
),

-- Final Transformation
transformed_users AS (
    SELECT 
        TRIM(USER_ID) AS user_id,
        INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown User'))) AS user_name,
        LOWER(TRIM(EMAIL)) AS email,
        INITCAP(TRIM(COALESCE(COMPANY, 'Unknown Company'))) AS company,
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Unknown'
        END AS plan_type,
        DATE(LOAD_TIMESTAMP) AS registration_date,
        DATE(UPDATE_TIMESTAMP) AS last_login_date,
        CASE 
            WHEN data_quality_score >= 0.8 THEN 'Active'
            WHEN data_quality_score >= 0.5 THEN 'Inactive'
            ELSE 'Suspended'
        END AS account_status,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        data_quality_score,
        DATE(LOAD_TIMESTAMP) AS load_date,
        DATE(UPDATE_TIMESTAMP) AS update_date
    FROM data_quality_checks
    WHERE rn = 1  -- Remove duplicates
        AND data_quality_score > 0.0  -- Remove records with critical quality issues
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
FROM transformed_users
