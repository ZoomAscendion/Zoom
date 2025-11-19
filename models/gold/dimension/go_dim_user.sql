{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_DIM_USER\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_DIM_USER' AS process_name, 'DIMENSION_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_USERS' AS source_table_name, 'GO_DIM_USER' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_DIM_USER' AND execution_status = 'RUNNING'"
) }}

WITH source_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_DATE,
        VALIDATION_STATUS,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY USER_ID) AS user_dim_id,
    USER_ID AS user_id,
    INITCAP(TRIM(COALESCE(USER_NAME, 'Unknown User'))) AS user_name,
    UPPER(SUBSTRING(COALESCE(EMAIL, 'unknown@domain.com'), POSITION('@' IN COALESCE(EMAIL, 'unknown@domain.com')) + 1)) AS email_domain,
    INITCAP(TRIM(COALESCE(COMPANY, 'Unknown Company'))) AS company,
    CASE 
        WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) IN ('FREE', 'BASIC') THEN 'Basic'
        WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
        WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
        ELSE 'Unknown'
    END AS plan_type,
    CASE 
        WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) = 'FREE' THEN 'Free'
        ELSE 'Paid'
    END AS plan_category,
    COALESCE(LOAD_DATE, CURRENT_DATE()) AS registration_date,
    CASE 
        WHEN VALIDATION_STATUS = 'PASSED' THEN 'Active'
        ELSE 'Inactive'
    END AS user_status,
    'Unknown' AS geographic_region,
    'Unknown' AS industry_sector,
    'Standard User' AS user_role,
    CASE 
        WHEN UPPER(COALESCE(PLAN_TYPE, 'UNKNOWN')) = 'FREE' THEN 'Individual'
        ELSE 'Business'
    END AS account_type,
    'English' AS language_preference,
    CURRENT_DATE() AS effective_start_date,
    '9999-12-31'::DATE AS effective_end_date,
    TRUE AS is_current_record,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM source_users
