{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_fact_feature_usage', 'SI_FEATURE_USAGE', 'go_fact_feature_usage', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_fact_feature_usage' AND process_status = 'STARTED'"
) }}

-- Feature usage fact table
WITH source_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        source_system
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE usage_date IS NOT NULL
      AND feature_name IS NOT NULL
      AND usage_count IS NOT NULL
),

feature_usage_facts AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY fu.usage_date, fu.feature_name, fu.usage_id) AS feature_usage_id,
        dd.date_id,
        df.feature_id,
        du.user_dim_id,
        fu.meeting_id,
        fu.usage_date,
        fu.usage_date::TIMESTAMP_NTZ AS usage_timestamp,
        fu.feature_name,
        fu.usage_count,
        0 AS usage_duration_minutes,
        0 AS session_duration_minutes,
        CASE 
            WHEN fu.usage_count >= 10 THEN 5.0
            WHEN fu.usage_count >= 5 THEN 4.0
            WHEN fu.usage_count >= 3 THEN 3.0
            WHEN fu.usage_count >= 1 THEN 2.0
            ELSE 1.0
        END AS feature_adoption_score,
        4.0 AS user_experience_rating,
        5.0 AS feature_performance_score,
        1 AS concurrent_features_count,
        'Standard Session' AS usage_context,
        'Desktop' AS device_type,
        'Latest' AS platform_version,
        0 AS error_count,
        100.0 AS success_rate,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        fu.source_system
    FROM source_feature_usage fu
    LEFT JOIN {{ ref('go_dim_date') }} dd ON fu.usage_date = dd.date_value
    LEFT JOIN {{ ref('go_dim_feature') }} df ON UPPER(TRIM(fu.feature_name)) = UPPER(TRIM(df.feature_name))
    LEFT JOIN {{ ref('go_dim_user') }} du ON du.user_dim_id = 1  -- Simplified join
)

SELECT * FROM feature_usage_facts
