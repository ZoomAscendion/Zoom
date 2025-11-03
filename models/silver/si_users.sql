{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (audit_id, execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, data_lineage_info, load_date, update_date, source_system) SELECT '{{ dbt_utils.generate_surrogate_key(['SI_USERS', var('current_timestamp')]) }}', '{{ dbt_utils.generate_surrogate_key(['SI_USERS', var('current_timestamp')]) }}', 'SI_USERS_TRANSFORMATION', '{{ var('current_timestamp') }}', 'STARTED', 'BZ_USERS', 'SI_USERS', '{{ var('audit_user') }}', 'PROD', 'Bronze to Silver transformation for users data', CURRENT_DATE(), CURRENT_DATE(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (audit_id, execution_id, pipeline_name, start_time, end_time, status, execution_duration_seconds, source_tables_processed, target_tables_updated, records_processed, records_inserted, records_updated, records_rejected, executed_by, execution_environment, data_lineage_info, load_date, update_date, source_system) SELECT '{{ dbt_utils.generate_surrogate_key(['SI_USERS_COMPLETE', var('current_timestamp')]) }}', '{{ dbt_utils.generate_surrogate_key(['SI_USERS', var('current_timestamp')]) }}', 'SI_USERS_TRANSFORMATION', '{{ var('current_timestamp') }}', CURRENT_TIMESTAMP(), 'SUCCESS', DATEDIFF('second', '{{ var('current_timestamp') }}', CURRENT_TIMESTAMP()), 'BZ_USERS', 'SI_USERS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 0, 0, '{{ var('audit_user') }}', 'PROD', 'Successfully completed Bronze to Silver transformation for users data', CURRENT_DATE(), CURRENT_DATE(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Users Transformation
-- Transforms Bronze layer user data into clean, standardized Silver layer format
-- Implements comprehensive data quality checks and validations

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
    FROM {{ ref('bz_users') }}
    WHERE USER_ID IS NOT NULL
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        USER_ID,
        
        -- Standardize user name with proper case formatting
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'Unknown User'
            ELSE TRIM(UPPER(LEFT(USER_NAME, 1)) || LOWER(SUBSTRING(USER_NAME, 2)))
        END as USER_NAME_CLEAN,
        
        -- Email validation and standardization
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN NULL
            WHEN REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$') 
                THEN LOWER(TRIM(EMAIL))
            ELSE NULL
        END as EMAIL_CLEAN,
        
        -- Company name standardization
        CASE 
            WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' THEN 'Unknown Company'
            ELSE TRIM(INITCAP(COMPANY))
        END as COMPANY_CLEAN,
        
        -- Plan type standardization
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
                THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'UNKNOWN'
        END as PLAN_TYPE_CLEAN,
        
        -- Derive account status from plan type and activity
        CASE 
            WHEN PLAN_TYPE IS NULL THEN 'INACTIVE'
            WHEN UPPER(TRIM(PLAN_TYPE)) = 'FREE' THEN 'ACTIVE'
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('BASIC', 'PRO', 'ENTERPRISE') THEN 'ACTIVE'
            ELSE 'SUSPENDED'
        END as ACCOUNT_STATUS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$') THEN 0.25 ELSE 0 END +
            CASE WHEN USER_NAME IS NOT NULL AND TRIM(USER_NAME) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN PLAN_TYPE IS NOT NULL AND UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 0.25 ELSE 0 END
        ) as DATA_QUALITY_SCORE
    FROM bronze_users
),

-- Remove duplicates keeping the latest record
deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM data_quality_checks
),

-- Final transformation
final_users AS (
    SELECT 
        USER_ID,
        USER_NAME_CLEAN as USER_NAME,
        EMAIL_CLEAN as EMAIL,
        COMPANY_CLEAN as COMPANY,
        PLAN_TYPE_CLEAN as PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) as REGISTRATION_DATE,
        DATE(UPDATE_TIMESTAMP) as LAST_LOGIN_DATE,
        ACCOUNT_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduplication
    WHERE rn = 1
      AND EMAIL_CLEAN IS NOT NULL  -- Block records without valid email
      AND DATA_QUALITY_SCORE >= 0.5  -- Minimum quality threshold
)

SELECT * FROM final_users
