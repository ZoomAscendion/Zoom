{{ config(
    materialized='table',
    cluster_by=['USAGE_DATE', 'FEATURE_NAME'],
    tags=['fact', 'feature_usage']
) }}

-- Feature usage fact table capturing detailed metrics and patterns
-- Combines feature usage data with meeting context and performance metrics

WITH source_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        validation_status,
        data_quality_score
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
        AND usage_count > 0
),

meeting_context AS (
    SELECT 
        meeting_id,
        duration_minutes,
        start_time,
        end_time
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
),

feature_aggregations AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT feature_name) AS total_features_per_meeting
    FROM source_feature_usage
    GROUP BY meeting_id
),

error_metrics AS (
    SELECT 
        meeting_id,
        feature_name,
        COUNT(*) AS error_count,
        COUNT(*) * 1.0 / NULLIF(SUM(usage_count), 0) AS error_rate
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = 'FAILED'
    GROUP BY meeting_id, feature_name
),

feature_usage_calculations AS (
    SELECT 
        fu.usage_id,
        fu.usage_date,
        CURRENT_TIMESTAMP() AS usage_timestamp,
        fu.feature_name,
        fu.usage_count,
        
        -- Calculate proportional usage duration
        CASE 
            WHEN mc.duration_minutes > 0 AND fa.total_features_per_meeting > 0 THEN 
                (fu.usage_count * 1.0 / fa.total_features_per_meeting) * mc.duration_minutes
            ELSE 0
        END AS usage_duration_minutes,
        
        COALESCE(mc.duration_minutes, 0) AS session_duration_minutes,
        
        -- Usage intensity classification
        CASE 
            WHEN fu.usage_count >= 20 THEN 'Very High'
            WHEN fu.usage_count >= 10 THEN 'High'
            WHEN fu.usage_count >= 5 THEN 'Medium'
            WHEN fu.usage_count >= 2 THEN 'Low'
            ELSE 'Very Low'
        END AS usage_intensity,
        
        -- User experience score (0-10 scale)
        CASE 
            WHEN fu.usage_count > 0 AND mc.duration_minutes > 0 THEN 
                LEAST(10.0, 
                    (fu.usage_count * 1.5) + 
                    (mc.duration_minutes / 15.0) + 
                    (fa.total_features_per_meeting * 0.5)
                )
            ELSE 0
        END AS user_experience_score,
        
        -- Feature performance score based on error rates
        CASE 
            WHEN fu.usage_count > 0 THEN 
                GREATEST(1.0, 10.0 - (COALESCE(em.error_rate, 0) * 10))
            ELSE 5.0
        END AS feature_performance_score,
        
        COALESCE(fa.total_features_per_meeting, 1) AS concurrent_features_count,
        COALESCE(em.error_count, 0) AS error_count,
        
        -- Success rate calculation
        CASE 
            WHEN fu.usage_count > 0 THEN 
                ((fu.usage_count - COALESCE(em.error_count, 0)) * 100.0 / fu.usage_count)
            ELSE 100.0
        END AS success_rate_percentage,
        
        -- Bandwidth consumption estimation (MB)
        CASE 
            WHEN UPPER(fu.feature_name) LIKE '%VIDEO%' THEN fu.usage_count * 75.0
            WHEN UPPER(fu.feature_name) LIKE '%SCREEN%SHARE%' THEN fu.usage_count * 50.0
            WHEN UPPER(fu.feature_name) LIKE '%RECORD%' THEN fu.usage_count * 100.0
            WHEN UPPER(fu.feature_name) LIKE '%AUDIO%' THEN fu.usage_count * 8.0
            WHEN UPPER(fu.feature_name) LIKE '%CHAT%' THEN fu.usage_count * 0.5
            WHEN UPPER(fu.feature_name) LIKE '%FILE%' THEN fu.usage_count * 25.0
            WHEN UPPER(fu.feature_name) LIKE '%WHITEBOARD%' THEN fu.usage_count * 15.0
            ELSE fu.usage_count * 3.0
        END AS bandwidth_consumed_mb,
        
        fu.source_system
        
    FROM source_feature_usage fu
    LEFT JOIN meeting_context mc ON fu.meeting_id = mc.meeting_id
    LEFT JOIN feature_aggregations fa ON fu.meeting_id = fa.meeting_id
    LEFT JOIN error_metrics em ON fu.meeting_id = em.meeting_id 
        AND fu.feature_name = em.feature_name
),

final_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY usage_date DESC, usage_timestamp DESC) AS feature_usage_id,
        usage_date,
        usage_timestamp,
        feature_name,
        usage_count,
        usage_duration_minutes,
        session_duration_minutes,
        usage_intensity,
        user_experience_score,
        feature_performance_score,
        concurrent_features_count,
        error_count,
        success_rate_percentage,
        bandwidth_consumed_mb,
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
        
    FROM feature_usage_calculations
)

SELECT * FROM final_fact
ORDER BY usage_date DESC, feature_name
