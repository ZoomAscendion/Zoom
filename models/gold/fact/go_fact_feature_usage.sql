{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_FACT_FEATURE_USAGE', run_started_at]) }}', 'GO_FACT_FEATURE_USAGE_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_FACT_FEATURE_USAGE', run_started_at]) }}'"
) }}

-- Feature usage fact table transformation
WITH feature_usage_base AS (
    SELECT 
        fu.usage_id,
        COALESCE(fu.meeting_id, 'UNKNOWN') AS meeting_id,
        COALESCE(fu.feature_name, 'Unknown Feature') AS feature_name,
        COALESCE(fu.usage_count, 1) AS usage_count,
        COALESCE(fu.usage_date, CURRENT_DATE()) AS usage_date,
        COALESCE(fu.source_system, 'UNKNOWN') AS source_system
    FROM {{ source('gold', 'si_feature_usage') }} fu
    WHERE fu.validation_status = 'PASSED'
),

feature_usage_fact AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY fub.usage_id) AS feature_usage_id,
        dd.date_id AS date_id,
        df.feature_id AS feature_id,
        1 AS user_dim_id, -- Default user
        fub.meeting_id,
        fub.usage_date,
        fub.usage_date::TIMESTAMP_NTZ AS usage_timestamp,
        fub.feature_name,
        fub.usage_count,
        30 AS usage_duration_minutes, -- Default duration
        30 AS session_duration_minutes, -- Default session
        CASE 
            WHEN fub.usage_count >= 10 THEN 5.0
            WHEN fub.usage_count >= 5 THEN 4.0
            WHEN fub.usage_count >= 3 THEN 3.0
            WHEN fub.usage_count >= 1 THEN 2.0
            ELSE 1.0
        END AS feature_adoption_score,
        CASE 
            WHEN fub.usage_count >= 10 THEN 5.0
            WHEN fub.usage_count >= 5 THEN 4.0
            WHEN fub.usage_count >= 3 THEN 3.0
            WHEN fub.usage_count >= 1 THEN 2.0
            ELSE 1.0
        END AS user_experience_rating,
        CASE 
            WHEN fub.usage_count > 0 THEN 5.0
            ELSE 1.0
        END AS feature_performance_score,
        1 AS concurrent_features_count,
        'Standard Session' AS usage_context,
        'Desktop' AS device_type,
        '1.0.0' AS platform_version,
        0 AS error_count,
        CASE 
            WHEN fub.usage_count > 0 THEN 100.0
            ELSE 0.0
        END AS success_rate,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        fub.source_system
    FROM feature_usage_base fub
    LEFT JOIN {{ ref('go_dim_date') }} dd ON fub.usage_date = dd.date_value
    LEFT JOIN {{ ref('go_dim_feature') }} df ON fub.feature_name = df.feature_name
)

SELECT * FROM feature_usage_fact
