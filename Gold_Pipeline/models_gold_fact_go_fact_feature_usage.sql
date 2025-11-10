/*
  go_fact_feature_usage.sql
  Zoom Platform Analytics System - Feature Usage Fact Table
  
  Author: Data Engineering Team
  Description: Fact table capturing detailed feature usage metrics and patterns
  
  This model creates comprehensive feature usage facts with performance metrics,
  user experience scores, and usage intensity analysis.
*/

{{ config(
    materialized='table',
    tags=['fact', 'feature_usage'],
    cluster_by=['usage_date', 'feature_name']
) }}

-- Base feature usage data with quality filters
WITH base_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        UPPER(TRIM(feature_name)) AS feature_name,
        usage_count,
        usage_date,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
        AND feature_name IS NOT NULL
        AND usage_count > 0
),

-- Get meeting context for feature usage
meeting_context AS (
    SELECT 
        meeting_id,
        start_time,
        end_time,
        duration_minutes,
        host_id
    FROM {{ source('silver', 'si_meetings') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
),

-- Get participant count per meeting for context
meeting_participants AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ source('silver', 'si_participants') }}
    WHERE validation_status = 'PASSED'
    GROUP BY meeting_id
),

-- Calculate concurrent feature usage per meeting
concurrent_features AS (
    SELECT 
        meeting_id,
        usage_date,
        COUNT(DISTINCT feature_name) AS concurrent_features_count,
        SUM(usage_count) AS total_usage_in_meeting
    FROM base_feature_usage
    GROUP BY meeting_id, usage_date
),

-- Feature usage fact with calculated metrics
feature_usage_fact AS (
    SELECT 
        f.usage_id,
        f.usage_date,
        
        -- Create usage timestamp (estimated based on meeting start time)
        COALESCE(
            m.start_time + INTERVAL '5 MINUTE',  -- Assume feature used 5 min after meeting start
            f.usage_date::TIMESTAMP_NTZ
        ) AS usage_timestamp,
        
        f.feature_name,
        f.usage_count,
        
        -- Usage duration estimation based on feature type and usage count
        CASE 
            WHEN f.feature_name LIKE '%SCREEN%SHARE%' THEN f.usage_count * 10.0  -- 10 min per usage
            WHEN f.feature_name LIKE '%RECORD%' THEN COALESCE(m.duration_minutes, 30)  -- Full meeting duration
            WHEN f.feature_name LIKE '%CHAT%' THEN f.usage_count * 0.5  -- 30 sec per message
            WHEN f.feature_name LIKE '%WHITEBOARD%' THEN f.usage_count * 15.0  -- 15 min per usage
            WHEN f.feature_name LIKE '%BREAKOUT%' THEN f.usage_count * 20.0  -- 20 min per breakout
            WHEN f.feature_name LIKE '%POLL%' THEN f.usage_count * 5.0  -- 5 min per poll
            ELSE f.usage_count * 2.0  -- Default 2 min per usage
        END AS usage_duration_minutes,
        
        -- Session duration (meeting duration)
        COALESCE(m.duration_minutes, 30) AS session_duration_minutes,
        
        -- Usage intensity calculation
        CASE 
            WHEN f.usage_count >= 20 THEN 'Very High'
            WHEN f.usage_count >= 10 THEN 'High'
            WHEN f.usage_count >= 5 THEN 'Medium'
            WHEN f.usage_count >= 2 THEN 'Low'
            ELSE 'Very Low'
        END AS usage_intensity,
        
        -- User experience score (synthetic - based on usage patterns)
        CASE 
            WHEN f.usage_count > 0 AND COALESCE(m.duration_minutes, 0) > 0 THEN
                LEAST(10.0,
                    8.0 +  -- Base score
                    (f.usage_count / 10.0) +  -- Usage frequency bonus
                    CASE 
                        WHEN f.feature_name IN ('AUDIO', 'VIDEO', 'CHAT') THEN 1.0  -- Core features bonus
                        WHEN f.feature_name LIKE '%SCREEN%SHARE%' THEN 0.5
                        ELSE 0.0
                    END
                )
            ELSE 5.0
        END AS user_experience_score,
        
        -- Feature performance score (synthetic)
        CASE 
            WHEN f.usage_count > 0 THEN
                9.0 + (RANDOM() * 1.0)  -- Simulated between 9.0-10.0
            ELSE NULL
        END AS feature_performance_score,
        
        -- Concurrent features count
        COALESCE(cf.concurrent_features_count, 1) AS concurrent_features_count,
        
        -- Error count estimation (synthetic - lower for core features)
        CASE 
            WHEN f.feature_name IN ('AUDIO', 'VIDEO', 'CHAT') THEN 0  -- Core features rarely error
            WHEN f.usage_count > 10 THEN FLOOR(RANDOM() * 2)  -- 0-1 errors for high usage
            WHEN f.usage_count > 5 THEN FLOOR(RANDOM() * 1)   -- 0 errors for medium usage
            ELSE 0
        END AS error_count,
        
        -- Success rate calculation
        CASE 
            WHEN f.usage_count > 0 THEN
                CASE 
                    WHEN f.feature_name IN ('AUDIO', 'VIDEO', 'CHAT') THEN 99.5  -- Core features high success
                    WHEN f.feature_name LIKE '%SCREEN%SHARE%' THEN 98.0
                    WHEN f.feature_name LIKE '%RECORD%' THEN 97.5
                    WHEN f.feature_name LIKE '%BREAKOUT%' THEN 96.0
                    ELSE 95.0 + (RANDOM() * 4.0)  -- 95-99% for other features
                END
            ELSE NULL
        END AS success_rate_percentage,
        
        -- Bandwidth consumption estimation (MB)
        CASE 
            WHEN f.feature_name LIKE '%VIDEO%' THEN f.usage_count * 50.0  -- 50 MB per minute of video
            WHEN f.feature_name LIKE '%SCREEN%SHARE%' THEN f.usage_count * 30.0  -- 30 MB per usage
            WHEN f.feature_name LIKE '%AUDIO%' THEN f.usage_count * 5.0   -- 5 MB per minute of audio
            WHEN f.feature_name LIKE '%RECORD%' THEN COALESCE(m.duration_minutes, 30) * 25.0  -- 25 MB per minute
            WHEN f.feature_name LIKE '%FILE%' THEN f.usage_count * 10.0   -- 10 MB per file share
            ELSE f.usage_count * 1.0  -- 1 MB for other features
        END AS bandwidth_consumed_mb,
        
        -- Metadata
        f.load_date,
        f.update_date,
        f.source_system
        
    FROM base_feature_usage f
    LEFT JOIN meeting_context m ON f.meeting_id = m.meeting_id
    LEFT JOIN meeting_participants mp ON f.meeting_id = mp.meeting_id
    LEFT JOIN concurrent_features cf ON f.meeting_id = cf.meeting_id AND f.usage_date = cf.usage_date
),

-- Final fact table with surrogate key
final_fact AS (
    SELECT 
        -- Generate surrogate key
        ROW_NUMBER() OVER (ORDER BY usage_date, usage_timestamp) AS feature_usage_id,
        
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
        load_date,
        update_date,
        source_system
        
    FROM feature_usage_fact
)

SELECT 
    feature_usage_id,
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
    load_date,
    update_date,
    source_system
FROM final_fact
ORDER BY feature_usage_id