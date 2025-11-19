{{ config(
    materialized='table'
) }}

-- Feature usage fact table with adoption and performance metrics
-- Joins Silver layer feature usage with Gold layer dimensions

WITH source_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        source_system,
        load_timestamp
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = 'PASSED'
      AND data_quality_score >= 70
      AND usage_date IS NOT NULL
      AND feature_name IS NOT NULL
),

meeting_context AS (
    SELECT 
        meeting_id,
        host_id,
        duration_minutes,
        start_time
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = 'PASSED'
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
        COALESCE(mc.duration_minutes, 0) AS usage_duration_minutes,
        COALESCE(mc.duration_minutes, 0) AS session_duration_minutes,
        -- Feature adoption score calculation
        CASE 
            WHEN fu.usage_count >= 10 THEN 5.0
            WHEN fu.usage_count >= 5 THEN 4.0
            WHEN fu.usage_count >= 3 THEN 3.0
            WHEN fu.usage_count >= 1 THEN 2.0
            ELSE 1.0
        END AS feature_adoption_score,
        -- User experience rating based on usage patterns
        CASE 
            WHEN fu.usage_count >= 5 AND mc.duration_minutes >= 30 THEN 5.0
            WHEN fu.usage_count >= 3 AND mc.duration_minutes >= 15 THEN 4.0
            WHEN fu.usage_count >= 1 AND mc.duration_minutes >= 5 THEN 3.0
            WHEN fu.usage_count >= 1 THEN 2.0
            ELSE 1.0
        END AS user_experience_rating,
        -- Feature performance score (simplified)
        CASE 
            WHEN fu.usage_count > 0 THEN 5.0
            ELSE 1.0
        END AS feature_performance_score,
        1 AS concurrent_features_count,  -- Simplified for now
        CASE 
            WHEN mc.duration_minutes >= 60 THEN 'Extended Session'
            WHEN mc.duration_minutes >= 30 THEN 'Standard Session'
            WHEN mc.duration_minutes >= 15 THEN 'Short Session'
            WHEN mc.duration_minutes >= 5 THEN 'Brief Session'
            ELSE 'Quick Access'
        END AS usage_context,
        'Desktop' AS device_type,  -- Default value
        'Latest' AS platform_version,  -- Default value
        0 AS error_count,  -- Default value
        CASE 
            WHEN fu.usage_count > 0 THEN 100.0
            ELSE 0.0
        END AS success_rate,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        fu.source_system
    FROM source_feature_usage fu
    LEFT JOIN {{ ref('go_dim_date') }} dd ON fu.usage_date = dd.date_value
    LEFT JOIN {{ ref('go_dim_feature') }} df ON UPPER(TRIM(fu.feature_name)) = UPPER(TRIM(df.feature_name))
    LEFT JOIN meeting_context mc ON fu.meeting_id = mc.meeting_id
    LEFT JOIN {{ ref('go_dim_user') }} du ON mc.host_id = du.user_id AND du.is_current_record = TRUE
)

SELECT * FROM feature_usage_facts
