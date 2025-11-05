{{ config(
    materialized='table'
) }}

WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
),

data_quality_checks AS (
    SELECT 
        *,
        -- Email validation
        CASE 
            WHEN email IS NULL OR TRIM(email) = '' THEN 0
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0
            ELSE 1
        END AS email_quality,
        
        -- Plan type validation
        CASE 
            WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 1
            ELSE 0
        END AS plan_type_quality,
        
        -- Completeness check
        CASE 
            WHEN user_id IS NOT NULL AND user_name IS NOT NULL THEN 1
            ELSE 0
        END AS completeness_quality,
        
        -- Temporal consistency
        CASE 
            WHEN update_timestamp >= load_timestamp THEN 1
            ELSE 0
        END AS temporal_quality
    FROM bronze_users
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY user_id 
            ORDER BY load_timestamp DESC, update_timestamp DESC
        ) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        user_id,
        TRIM(UPPER(user_name)) AS user_name,
        CASE 
            WHEN email IS NULL OR TRIM(email) = '' THEN NULL
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN NULL
            ELSE LOWER(TRIM(email))
        END AS email,
        TRIM(INITCAP(company)) AS company,
        CASE 
            WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN plan_type
            ELSE 'Unknown'
        END AS plan_type,
        DATE(load_timestamp) AS registration_date,
        DATE(update_timestamp) AS last_login_date,
        CASE 
            WHEN plan_type IN ('Pro', 'Enterprise') THEN 'Active'
            WHEN plan_type = 'Free' THEN 'Active'
            ELSE 'Inactive'
        END AS account_status,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Calculate data quality score
        ROUND(
            (email_quality + plan_type_quality + completeness_quality + temporal_quality) / 4.0, 2
        ) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM deduplication
    WHERE rn = 1
      AND user_id IS NOT NULL
      AND email IS NOT NULL
      AND REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
)

SELECT * FROM final_transformation
