{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_DIM_LICENSE\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_DIM_LICENSE' AS process_name, 'DIMENSION_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_LICENSES' AS source_table_name, 'GO_DIM_LICENSE' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_DIM_LICENSE' AND execution_status = 'RUNNING'"
) }}

WITH source_licenses AS (
    SELECT DISTINCT
        LICENSE_TYPE,
        START_DATE,
        END_DATE,
        SOURCE_SYSTEM
    FROM {{ ref('SI_Licenses') }}
    WHERE VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY LICENSE_TYPE) AS license_id,
    INITCAP(TRIM(LICENSE_TYPE)) AS license_type,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'Standard'
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'Professional'
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Enterprise'
        ELSE 'Other'
    END AS license_category,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'Tier 1'
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'Tier 2'
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Tier 3'
        ELSE 'Tier 0'
    END AS license_tier,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 100
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 500
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 1000
        ELSE 50
    END AS max_participants,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 5
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 100
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 1000
        ELSE 1
    END AS storage_limit_gb,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 40
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 100
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 500
        ELSE 0
    END AS recording_limit_hours,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
        ELSE FALSE
    END AS admin_features_included,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' OR UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
        ELSE FALSE
    END AS api_access_included,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
        ELSE FALSE
    END AS sso_support_included,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 14.99
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 19.99
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 39.99
        ELSE 0.00
    END AS monthly_price,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 149.90
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 199.90
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 399.90
        ELSE 0.00
    END AS annual_price,
    'Standard license benefits for ' || LICENSE_TYPE AS license_benefits,
    COALESCE(START_DATE, CURRENT_DATE()) AS effective_start_date,
    COALESCE(END_DATE, '9999-12-31'::DATE) AS effective_end_date,
    TRUE AS is_current_record,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM source_licenses
