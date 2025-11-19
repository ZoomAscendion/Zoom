{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_DIM_LICENSE', run_started_at]) }}', 'GO_DIM_LICENSE_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_LICENSES', 'GO_DIM_LICENSE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_DIM_LICENSE', run_started_at]) }}'"
) }}

-- License dimension transformation from Silver layer
WITH license_source AS (
    SELECT DISTINCT
        license_type,
        start_date,
        end_date,
        source_system
    FROM {{ source('silver', 'si_licenses') }}
    WHERE validation_status = 'PASSED'
),

license_transformed AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['license_type']) }} AS license_key,
        INITCAP(TRIM(license_type)) AS license_type,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 'Standard'
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 'Professional'
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 'Enterprise'
            ELSE 'Other'
        END AS license_category,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 'Tier 1'
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 'Tier 2'
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 'Tier 3'
            ELSE 'Tier 0'
        END AS license_tier,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 100
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 500
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 1000
            ELSE 50
        END AS max_participants,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 5
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 100
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 1000
            ELSE 1
        END AS storage_limit_gb,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 40
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 100
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 500
            ELSE 0
        END AS recording_limit_hours,
        CASE 
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS admin_features_included,
        CASE 
            WHEN UPPER(license_type) LIKE '%PRO%' OR UPPER(license_type) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS api_access_included,
        CASE 
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS sso_support_included,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 14.99
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 19.99
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 39.99
            ELSE 0.00
        END AS monthly_price,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 149.90
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 199.90
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 399.90
            ELSE 0.00
        END AS annual_price,
        'Standard license benefits for ' || license_type AS license_benefits,
        start_date AS effective_start_date,
        end_date AS effective_end_date,
        TRUE AS is_current_record,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM license_source
)

SELECT * FROM license_transformed
