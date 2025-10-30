{{ config(
    materialized='incremental',
    unique_key='user_id',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('audit_log') }} (
            execution_id, pipeline_name, start_time, status, executed_by, execution_environment, source_system
        ) 
        SELECT 
            '{{ invocation_id }}_users' as execution_id,
            'si_users_pipeline' as pipeline_name,
            CURRENT_TIMESTAMP() as start_time,
            'RUNNING' as status,
            CURRENT_USER() as executed_by,
            'PROD' as execution_environment,
            'DBT_SILVER_PIPELINE' as source_system
    ",
    post_hook="
        UPDATE {{ ref('audit_log') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP())
        WHERE execution_id = '{{ invocation_id }}_users'
    "
) }}

-- Silver layer transformation for users with comprehensive data quality checks
WITH bronze_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM {{ source('bronze', 'bz_users') }}
    WHERE USER_ID IS NOT NULL 
    AND TRIM(USER_ID) != ''
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Data quality validation and cleansing
cleansed_users AS (
    SELECT 
        TRIM(USER_ID) as user_id,
        INITCAP(TRIM(USER_NAME)) as user_name,
        LOWER(TRIM(EMAIL)) as email,
        INITCAP(TRIM(COMPANY)) as company,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'FREE'
        END as plan_type,
        DATE(LOAD_TIMESTAMP) as registration_date,
        DATE(UPDATE_TIMESTAMP) as last_login_date,
        CASE 
            WHEN UPDATE_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '30 days' THEN 'Active'
            WHEN UPDATE_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '90 days' THEN 'Inactive'
            ELSE 'Suspended'
        END as account_status,
        LOAD_TIMESTAMP as load_timestamp,
        UPDATE_TIMESTAMP as update_timestamp,
        SOURCE_SYSTEM as source_system,
        -- Calculate data quality score
        (
            CASE WHEN USER_ID IS NOT NULL AND TRIM(USER_ID) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN USER_NAME IS NOT NULL AND TRIM(USER_NAME) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0.25 ELSE 0 END +
            CASE WHEN PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 0.25 ELSE 0 END
        ) as data_quality_score,
        CURRENT_DATE() as load_date,
        CURRENT_DATE() as update_date
    FROM bronze_users
    WHERE rn = 1
    AND EMAIL IS NOT NULL
    AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
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
FROM cleansed_users
WHERE data_quality_score >= 0.75  -- Only accept high quality records
