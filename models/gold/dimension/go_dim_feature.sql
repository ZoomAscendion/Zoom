{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_DIM_FEATURE', run_started_at]) }}', 'GO_DIM_FEATURE_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_DIM_FEATURE', run_started_at]) }}'"
) }}

-- Feature dimension transformation from Silver layer
WITH feature_source AS (
    SELECT DISTINCT
        COALESCE(feature_name, 'Unknown Feature') AS feature_name,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM {{ source('gold', 'si_feature_usage') }}
    WHERE validation_status = 'PASSED'
      AND feature_name IS NOT NULL
),

feature_transformed AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY feature_name) AS feature_id,
        {{ dbt_utils.generate_surrogate_key(['feature_name']) }} AS feature_key,
        INITCAP(TRIM(feature_name)) AS feature_name,
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
            WHEN UPPER(feature_name) LIKE '%POLL%' THEN 'Engagement'
            ELSE 'General'
        END AS feature_category,
        CASE 
            WHEN UPPER(feature_name) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(feature_name) LIKE '%ADVANCED%' THEN 'Advanced'
            ELSE 'Standard'
        END AS feature_type,
        CASE 
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%POLL%' THEN 'High'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Medium'
            ELSE 'Low'
        END AS feature_complexity,
        CASE 
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%BREAKOUT%' THEN TRUE
            ELSE FALSE
        END AS is_premium_feature,
        '2020-01-01'::DATE AS feature_release_date,
        'Active' AS feature_status,
        'Medium' AS usage_frequency_category,
        'Feature usage tracking for ' || feature_name AS feature_description,
        'All Users' AS target_user_segment,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM feature_source
)

SELECT * FROM feature_transformed
