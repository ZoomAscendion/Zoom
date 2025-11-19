{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_DIM_FEATURE\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_DIM_FEATURE' AS process_name, 'DIMENSION_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SI_FEATURE_USAGE' AS source_table_name, 'GO_DIM_FEATURE' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_DIM_FEATURE' AND execution_status = 'RUNNING'"
) }}

WITH source_features AS (
    SELECT DISTINCT
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY FEATURE_NAME) AS feature_id,
    INITCAP(TRIM(FEATURE_NAME)) AS feature_name,
    CASE 
        WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
        WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording'
        WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication'
        WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
        WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Engagement'
        ELSE 'General'
    END AS feature_category,
    CASE 
        WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'Core'
        WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN 'Advanced'
        ELSE 'Standard'
    END AS feature_type,
    CASE 
        WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'High'
        WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Medium'
        ELSE 'Low'
    END AS feature_complexity,
    CASE 
        WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN TRUE
        ELSE FALSE
    END AS is_premium_feature,
    '2020-01-01'::DATE AS feature_release_date,
    'Active' AS feature_status,
    'Medium' AS usage_frequency_category,
    'Feature usage tracking for ' || FEATURE_NAME AS feature_description,
    'All Users' AS target_user_segment,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS source_system
FROM source_features
