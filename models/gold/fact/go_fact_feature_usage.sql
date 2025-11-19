{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_FACT_FEATURE_USAGE', run_started_at]) }}', 'GO_FACT_FEATURE_USAGE_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_FACT_FEATURE_USAGE', run_started_at]) }}'"
) }}

-- Feature usage fact table transformation
WITH feature_usage_base AS (
    SELECT 
        fu.usage_id,
        fu.meeting_id,
        fu.feature_name,
        fu.usage_count,
        fu.usage_date,
        fu.source_system
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.validation_status = 'PASSED'
),

meeting_context AS (
    SELECT 
        sm.meeting_id,
        sm.host_id,
        sm.duration_minutes
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE sm.validation_status = 'PASSED'
),

feature_usage_fact AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['fub.usage_id']) }} AS feature_usage_id,
        dd.date_id AS date_id,
        df.feature_id AS feature_id,
        du.user_dim_id AS user_dim_id,
        fub.meeting_id,
        fub.usage_date,
        fub.usage_date::TIMESTAMP_NTZ AS usage_timestamp,
        fub.feature_name,
        fub.usage_count,
        COALESCE(mc.duration_minutes, 0) AS usage_duration_minutes,
        COALESCE(mc.duration_minutes, 0) AS session_duration_minutes,
        CASE 
            WHEN fub.usage_count >= 10 THEN 5.0
            WHEN fub.usage_count >= 5 THEN 4.0
            WHEN fub.usage_count >= 3 THEN 3.0
            WHEN fub.usage_count >= 1 THEN 2.0
            ELSE 1.0
        END AS feature_adoption_score,
        CASE 
            WHEN fub.usage_count >= 10 AND COALESCE(mc.duration_minutes, 0) >= 60 THEN 5.0
            WHEN fub.usage_count >= 5 AND COALESCE(mc.duration_minutes, 0) >= 30 THEN 4.0
            WHEN fub.usage_count >= 3 AND COALESCE(mc.duration_minutes, 0) >= 15 THEN 3.0
            WHEN fub.usage_count >= 1 THEN 2.0
            ELSE 1.0
        END AS user_experience_rating,
        CASE 
            WHEN fub.usage_count > 0 THEN 5.0
            ELSE 1.0
        END AS feature_performance_score,
        1 AS concurrent_features_count,
        CASE 
            WHEN COALESCE(mc.duration_minutes, 0) >= 60 THEN 'Extended Session'
            WHEN COALESCE(mc.duration_minutes, 0) >= 30 THEN 'Standard Session'
            WHEN COALESCE(mc.duration_minutes, 0) >= 15 THEN 'Short Session'
            WHEN COALESCE(mc.duration_minutes, 0) >= 5 THEN 'Brief Session'
            ELSE 'Quick Access'
        END AS usage_context,
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
    LEFT JOIN meeting_context mc ON fub.meeting_id = mc.meeting_id
    LEFT JOIN {{ ref('go_dim_user') }} du ON mc.host_id = du.user_id AND du.is_current_record = TRUE
)

SELECT * FROM feature_usage_fact
