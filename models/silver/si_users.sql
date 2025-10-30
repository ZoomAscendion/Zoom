{{ config(
    materialized='incremental',
    unique_key='user_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for users with data quality checks and deduplication
WITH bronze_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY update_timestamp DESC, load_timestamp DESC) as rn
    FROM {{ source('bronze', 'bz_users') }}
    WHERE user_id IS NOT NULL 
    AND TRIM(user_id) != ''
    {% if is_incremental() %}
        AND (update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
             OR load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }}))
    {% endif %}
),

deduped_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_users
    WHERE rn = 1
),

validated_users AS (
    SELECT 
        TRIM(user_id) AS user_id,
        CASE 
            WHEN user_name IS NOT NULL AND TRIM(user_name) != '' 
            THEN INITCAP(TRIM(user_name))
            ELSE 'Unknown User'
        END AS user_name,
        CASE 
            WHEN email IS NOT NULL 
            AND REGEXP_LIKE(LOWER(TRIM(email)), '^[a-za-z0-9._%+-]+@[a-za-z0-9.-]+\\.[a-za-z]{2,}$')
            THEN LOWER(TRIM(email))
            ELSE NULL
        END AS email,
        CASE 
            WHEN company IS NOT NULL AND TRIM(company) != ''
            THEN INITCAP(TRIM(company))
            ELSE 'Unknown Company'
        END AS company,
        CASE 
            WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN plan_type
            ELSE 'Unknown'
        END AS plan_type,
        DATE(load_timestamp) AS registration_date,
        DATE(update_timestamp) AS last_login_date,
        CASE 
            WHEN plan_type IN ('Pro', 'Enterprise') THEN 'Active'
            WHEN plan_type = 'Basic' THEN 'Active'
            WHEN plan_type = 'Free' THEN 'Active'
            ELSE 'Inactive'
        END AS account_status,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_users
),

final_users AS (
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
        -- Calculate data quality score
        ROUND(
            (CASE WHEN user_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN user_name != 'Unknown User' THEN 0.25 ELSE 0 END +
             CASE WHEN email IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN plan_type != 'Unknown' THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_users
)

SELECT * FROM final_users
