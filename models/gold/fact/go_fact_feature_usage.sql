{{ config(
    materialized='table',
    tags=['fact'],
    cluster_by=['USAGE_DATE', 'FEATURE_NAME']
) }}

-- Feature usage fact table with comprehensive metrics and KPIs
-- Transforms Silver feature usage data with business calculations

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
      AND fu.data_quality_score >= 80
      AND fu.usage_count > 0
      AND fu.feature_name IS NOT NULL
),

meeting_context AS (
    SELECT 
        m.meeting_id,
        m.duration_minutes,
        m.start_time,
        m.end_time
    FROM {{ source('silver', 'si_meetings') }} m
    WHERE m.validation_status = 'PASSED'
      AND m.data_quality_score >= 80
),

feature_aggregations AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT feature_name) AS total_features_used
    FROM feature_usage_base
    GROUP BY meeting_id
),

error_metrics AS (
    SELECT 
        fu.meeting_id,
        fu.feature_name,
        COUNT(*) AS error_count,
        COUNT(*) * 1.0 / NULLIF(SUM(fu.usage_count), 0) AS error_rate
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.validation_status = 'FAILED'
    GROUP BY fu.meeting_id, fu.feature_name
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY fub.usage_date, fub.meeting_id, fub.feature_name) AS feature_usage_id,
    
    -- Date and time dimensions
    fub.usage_date,
    CURRENT_TIMESTAMP() AS usage_timestamp,
    
    -- Core metrics
    fub.feature_name,
    fub.usage_count,
    
    -- Duration calculations
    CASE 
        WHEN mc.duration_minutes > 0 AND fa.total_features_used > 0 THEN 
            (fub.usage_count * 1.0 / fa.total_features_used) * mc.duration_minutes
        ELSE 0
    END AS usage_duration_minutes,
    
    COALESCE(mc.duration_minutes, 0) AS session_duration_minutes,
    
    -- Usage intensity classification
    CASE 
        WHEN fub.usage_count >= 10 THEN 'High'
        WHEN fub.usage_count >= 5 THEN 'Medium'
        ELSE 'Low'
    END AS usage_intensity,
    
    -- User experience score (1-10 scale)
    CASE 
        WHEN fub.usage_count > 0 AND mc.duration_minutes > 0 THEN 
            LEAST(10.0, (fub.usage_count * 2.0) + (mc.duration_minutes / 10.0))
        ELSE 0
    END AS user_experience_score,
    
    -- Feature performance score
    CASE 
        WHEN fub.usage_count > 0 THEN 
            GREATEST(1.0, 10.0 - (COALESCE(em.error_rate, 0) * 10))
        ELSE 5.0
    END AS feature_performance_score,
    
    -- Concurrent features count
    COALESCE(fa.total_features_used, 1) AS concurrent_features_count,
    
    -- Error metrics
    COALESCE(em.error_count, 0) AS error_count,
    
    -- Success rate calculation
    CASE 
        WHEN fub.usage_count > 0 THEN 
            ((fub.usage_count - COALESCE(em.error_count, 0)) * 100.0 / fub.usage_count)
        ELSE 100.0
    END AS success_rate_percentage,
    
    -- Bandwidth estimation based on feature type
    CASE 
        WHEN UPPER(fub.feature_name) LIKE '%VIDEO%' THEN fub.usage_count * 50.0
        WHEN UPPER(fub.feature_name) LIKE '%SCREEN%' THEN fub.usage_count * 30.0
        WHEN UPPER(fub.feature_name) LIKE '%AUDIO%' THEN fub.usage_count * 5.0
        ELSE fub.usage_count * 2.0
    END AS bandwidth_consumed_mb,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    fub.source_system
    
FROM feature_usage_base fub
LEFT JOIN meeting_context mc ON fub.meeting_id = mc.meeting_id
LEFT JOIN feature_aggregations fa ON fub.meeting_id = fa.meeting_id
LEFT JOIN error_metrics em ON fub.meeting_id = em.meeting_id 
    AND fub.feature_name = em.feature_name
ORDER BY fub.usage_date, fub.meeting_id, fub.feature_name
