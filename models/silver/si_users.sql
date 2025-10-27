{{
  config(
    materialized='incremental',
    unique_key='user_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge',
    pre_hook="
      INSERT INTO {{ ref('audit_log') }} (
        audit_id, pipeline_name, start_time, status, execution_id, 
        execution_start_time, source_table, target_table, execution_status, 
        processed_by, load_timestamp
      )
      SELECT
        MD5('si_users_' || CURRENT_TIMESTAMP()::VARCHAR),
        'si_users_transformation',
        CURRENT_TIMESTAMP(),
        'RUNNING',
        MD5('exec_' || CURRENT_TIMESTAMP()::VARCHAR),
        CURRENT_TIMESTAMP(),
        'bz_users',
        'si_users',
        'STARTED',
        'DBT_SILVER_PIPELINE',
        CURRENT_TIMESTAMP()
    ",
    post_hook="
      INSERT INTO {{ ref('audit_log') }} (
        audit_id, pipeline_name, end_time, status, execution_id, 
        execution_end_time, source_table, target_table, execution_status, 
        processed_by, load_timestamp, records_processed
      )
      SELECT
        MD5('si_users_complete_' || CURRENT_TIMESTAMP()::VARCHAR),
        'si_users_transformation',
        CURRENT_TIMESTAMP(),
        'SUCCESS',
        MD5('exec_complete_' || CURRENT_TIMESTAMP()::VARCHAR),
        CURRENT_TIMESTAMP(),
        'bz_users',
        'si_users',
        'COMPLETED',
        'DBT_SILVER_PIPELINE',
        CURRENT_TIMESTAMP(),
        (SELECT COUNT(*) FROM {{ this }})
    "
  )
}}

-- Silver Users Table Transformation
-- Transforms bronze user data with data quality validations and derived attributes

WITH bronze_users AS (
    SELECT 
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_users') }}
    WHERE user_name IS NOT NULL 
      AND email IS NOT NULL
      AND REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
      AND plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise')
),

deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LOWER(TRIM(email)) 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM bronze_users
),

transformed_users AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['email', 'user_name']) }} AS user_id,
        
        -- Direct Mappings with Cleansing
        TRIM(user_name) AS user_name,
        LOWER(TRIM(email)) AS email,
        
        -- Derived Attributes
        SPLIT_PART(LOWER(TRIM(email)), '@', 2) AS email_domain,
        COALESCE(TRIM(company), 'Unknown') AS company,
        plan_type,
        
        -- Date Attributes
        COALESCE(DATE(load_timestamp), CURRENT_DATE()) AS registration_date,
        DATEDIFF(day, COALESCE(DATE(load_timestamp), CURRENT_DATE()), CURRENT_DATE()) AS account_age_days,
        
        -- Business Logic Derived Fields
        CASE 
            WHEN plan_type = 'Enterprise' THEN 'Enterprise'
            WHEN plan_type = 'Pro' THEN 'Professional'
            WHEN plan_type = 'Basic' THEN 'Standard'
            ELSE 'Free'
        END AS user_segment,
        
        CASE 
            WHEN SPLIT_PART(LOWER(TRIM(email)), '@', 2) LIKE '%.com' THEN 'North America'
            WHEN SPLIT_PART(LOWER(TRIM(email)), '@', 2) LIKE '%.uk' THEN 'Europe'
            WHEN SPLIT_PART(LOWER(TRIM(email)), '@', 2) LIKE '%.de' THEN 'Europe'
            WHEN SPLIT_PART(LOWER(TRIM(email)), '@', 2) LIKE '%.jp' THEN 'Asia Pacific'
            ELSE 'Unknown'
        END AS geographic_region,
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system,
        load_timestamp,
        update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN user_name IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN email IS NOT NULL AND REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0.25 ELSE 0 END +
             CASE WHEN company IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_users
    WHERE row_num = 1
)

SELECT * FROM transformed_users

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
