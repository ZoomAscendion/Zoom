{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_FACT_FEATURE_USAGE_TRANSFORMATION', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'STARTED', 'Feature usage fact transformation started', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_FACT_FEATURE_USAGE_TRANSFORMATION', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'COMPLETED', 'Feature usage fact transformation completed successfully', CURRENT_DATE(), CURRENT_DATE())"
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
        m.DURATION_MINUTES,
        m.HOST_ID,
        fu.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }} fu
    LEFT JOIN {{ source('silver', 'si_meetings') }} m 
        ON fu.MEETING_ID = m.MEETING_ID
    WHERE fu.VALIDATION_STATUS = 'PASSED'
        AND fu.DATA_QUALITY_SCORE >= 80
        AND fu.USAGE_COUNT > 0
),

total_features_per_meeting AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT FEATURE_NAME) AS feature_count
    FROM feature_usage_base
    GROUP BY MEETING_ID
),

error_metrics AS (
    SELECT 
        MEETING_ID,
        FEATURE_NAME,
        COUNT(*) AS error_count,
        COUNT(*) * 1.0 / NULLIF(SUM(USAGE_COUNT), 0) AS error_rate
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'FAILED'
    GROUP BY MEETING_ID, FEATURE_NAME
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
            WHEN fub.DURATION_MINUTES > 0 AND tfpm.feature_count > 0 THEN 
                (fub.USAGE_COUNT * 1.0 / tfpm.feature_count) * fub.DURATION_MINUTES
            ELSE 0
        END AS USAGE_DURATION_MINUTES,
        COALESCE(fub.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
        -- Usage intensity classification
        CASE 
            WHEN fub.USAGE_COUNT >= 10 THEN 'High'
            WHEN fub.USAGE_COUNT >= 5 THEN 'Medium'
            ELSE 'Low'
        END AS USAGE_INTENSITY,
        -- User experience score calculation
        CASE 
            WHEN fub.USAGE_COUNT > 0 AND fub.DURATION_MINUTES > 0 THEN 
                LEAST(10.0, (fub.USAGE_COUNT * 2.0) + (fub.DURATION_MINUTES / 10.0))
            ELSE 0
        END AS USER_EXPERIENCE_SCORE,
        -- Feature performance score
        CASE 
            WHEN fub.USAGE_COUNT > 0 THEN 
                GREATEST(1.0, 10.0 - (COALESCE(em.error_rate, 0) * 10))
            ELSE 5.0
        END AS FEATURE_PERFORMANCE_SCORE,
        COALESCE(tfpm.feature_count, 1) AS CONCURRENT_FEATURES_COUNT,
        COALESCE(em.error_count, 0) AS ERROR_COUNT,
        -- Success rate calculation
        CASE 
            WHEN fub.USAGE_COUNT > 0 THEN 
                ((fub.USAGE_COUNT - COALESCE(em.error_count, 0)) * 100.0 / fub.USAGE_COUNT)
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
    LEFT JOIN total_features_per_meeting tfpm 
        ON fub.MEETING_ID = tfpm.MEETING_ID
    LEFT JOIN error_metrics em 
        ON fub.MEETING_ID = em.MEETING_ID 
        AND fub.FEATURE_NAME = em.FEATURE_NAME
)

SELECT * FROM feature_usage_metrics
ORDER BY FEATURE_USAGE_ID
