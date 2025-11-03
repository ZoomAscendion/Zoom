{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('si_pipeline_audit') }} (
            execution_id, pipeline_name, start_time, status, 
            source_tables_processed, executed_by, execution_environment,
            load_date, update_date, source_system
        )
        VALUES (
            '{{ invocation_id }}_si_users', 
            'si_users', 
            CURRENT_TIMESTAMP(), 
            'STARTED',
            'BZ_USERS',
            '{{ var(\"audit_user\") }}',
            'PRODUCTION',
            CURRENT_DATE(),
            CURRENT_DATE(),
            'DBT_SILVER_PIPELINE'
        )
    ",
    post_hook="
        UPDATE {{ ref('si_pipeline_audit') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
            target_tables_updated = 'SI_USERS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            records_inserted = (SELECT COUNT(*) FROM {{ this }}),
            records_updated = 0,
            records_rejected = 0,
            update_date = CURRENT_DATE()
        WHERE execution_id = '{{ invocation_id }}_si_users'
    "
) }}

-- Silver layer transformation for Users
WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Checks and Cleansing
cleansed_users AS (
    SELECT 
        user_id,
        TRIM(UPPER(user_name)) AS user_name_clean,
        LOWER(TRIM(email)) AS email_clean,
        TRIM(INITCAP(company)) AS company_clean,
        CASE 
            WHEN UPPER(plan_type) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(plan_type)
            ELSE 'UNKNOWN_PLAN'
        END AS plan_type_standardized,
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data Quality Validations
        CASE 
            WHEN user_id IS NULL THEN 0
            WHEN email IS NULL OR TRIM(email) = '' THEN 0
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(email)), '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$') THEN 0
            ELSE 1
        END AS email_valid,
        
        CASE 
            WHEN user_name IS NULL OR TRIM(user_name) = '' THEN 0
            ELSE 1
        END AS name_valid,
        
        CASE 
            WHEN UPPER(plan_type) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 1
            ELSE 0
        END AS plan_type_valid
),

-- Remove duplicates keeping latest record
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS rn
    FROM cleansed_users
    WHERE user_id IS NOT NULL
    AND email_valid = 1
),

-- Final transformation with derived fields
final_users AS (
    SELECT 
        user_id,
        user_name_clean AS user_name,
        email_clean AS email,
        company_clean AS company,
        plan_type_standardized AS plan_type,
        DATE(load_timestamp) AS registration_date,
        DATE(update_timestamp) AS last_login_date,
        CASE 
            WHEN plan_type_standardized IN ('PRO', 'ENTERPRISE') THEN 'Active'
            WHEN plan_type_standardized = 'BASIC' THEN 'Active'
            WHEN plan_type_standardized = 'FREE' THEN 'Active'
            ELSE 'Inactive'
        END AS account_status,
        
        -- Metadata columns
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data quality score calculation
        ROUND(
            (email_valid + name_valid + plan_type_valid) / 3.0, 2
        ) AS data_quality_score,
        
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
        
    FROM deduped_users
    WHERE rn = 1
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
FROM final_users
