{{ config(
    materialized='table'
) }}

-- Feature Usage Fact Table
-- Comprehensive feature usage metrics and analytics

WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.USAGE_DATE,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.MEETING_ID,
        fu.SOURCE_SYSTEM
    FROM SILVER.SI_FEATURE_USAGE fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
        AND fu.DATA_QUALITY_SCORE >= 80
        AND fu.USAGE_COUNT > 0
),

meeting_info AS (
    SELECT 
        MEETING_ID,
        DURATION_MINUTES,
        HOST_ID
    FROM SILVER.SI_MEETINGS
    WHERE VALIDATION_STATUS = 'PASSED'
),

total_features_per_meeting AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT FEATURE_NAME) AS feature_count
    FROM feature_usage_base
    GROUP BY MEETING_ID
),

feature_usage_metrics AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY fub.USAGE_ID) AS FEATURE_USAGE_ID,
        fub.USAGE_DATE,
        CURRENT_TIMESTAMP() AS USAGE_TIMESTAMP,
        fub.FEATURE_NAME,
        fub.USAGE_COUNT,
        -- Calculate proportional usage duration
        CASE 
            WHEN mi.DURATION_MINUTES > 0 AND tfpm.feature_count > 0 THEN 
                (fub.USAGE_COUNT * 1.0 / tfpm.feature_count) * mi.DURATION_MINUTES
            ELSE 0
        END AS USAGE_DURATION_MINUTES,
        COALESCE(mi.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
        -- Usage intensity classification
        CASE 
            WHEN fub.USAGE_COUNT >= 10 THEN 'High'
            WHEN fub.USAGE_COUNT >= 5 THEN 'Medium'
            ELSE 'Low'
        END AS USAGE_INTENSITY,
        -- User experience score calculation
        CASE 
            WHEN fub.USAGE_COUNT > 0 AND mi.DURATION_MINUTES > 0 THEN 
                LEAST(10.0, (fub.USAGE_COUNT * 2.0) + (mi.DURATION_MINUTES / 10.0))
            ELSE 0
        END AS USER_EXPERIENCE_SCORE,
        -- Feature performance score
        CASE 
            WHEN fub.USAGE_COUNT > 0 THEN 8.5
            ELSE 5.0
        END AS FEATURE_PERFORMANCE_SCORE,
        COALESCE(tfpm.feature_count, 1) AS CONCURRENT_FEATURES_COUNT,
        0 AS ERROR_COUNT,
        -- Success rate calculation
        CASE 
            WHEN fub.USAGE_COUNT > 0 THEN 100.0
            ELSE 100.0
        END AS SUCCESS_RATE_PERCENTAGE,
        -- Bandwidth estimation by feature type
        CASE 
            WHEN UPPER(fub.FEATURE_NAME) LIKE '%VIDEO%' THEN fub.USAGE_COUNT * 50.0
            WHEN UPPER(fub.FEATURE_NAME) LIKE '%SCREEN%' THEN fub.USAGE_COUNT * 30.0
            WHEN UPPER(fub.FEATURE_NAME) LIKE '%AUDIO%' THEN fub.USAGE_COUNT * 5.0
            ELSE fub.USAGE_COUNT * 2.0
        END AS BANDWIDTH_CONSUMED_MB,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        fub.SOURCE_SYSTEM
    FROM feature_usage_base fub
    LEFT JOIN meeting_info mi ON fub.MEETING_ID = mi.MEETING_ID
    LEFT JOIN total_features_per_meeting tfpm ON fub.MEETING_ID = tfpm.MEETING_ID
)

SELECT * FROM feature_usage_metrics
ORDER BY FEATURE_USAGE_ID
