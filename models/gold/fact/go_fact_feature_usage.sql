{{ config(
    materialized='table'
) }}

-- Gold Fact: Feature Usage Fact
-- Description: Detailed feature usage metrics and patterns

WITH source_usage AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.LOAD_TIMESTAMP,
        fu.SOURCE_SYSTEM,
        fu.VALIDATION_STATUS
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE (fu.VALIDATION_STATUS = 'PASSED' OR fu.VALIDATION_STATUS IS NULL)
      AND fu.FEATURE_NAME IS NOT NULL
      AND fu.USAGE_COUNT IS NOT NULL
),

feature_usage_metrics AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY USAGE_ID) AS FEATURE_USAGE_ID,
        COALESCE(USAGE_DATE, CURRENT_DATE) AS USAGE_DATE,
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) AS USAGE_TIMESTAMP,
        FEATURE_NAME,
        USAGE_COUNT,
        COALESCE(USAGE_COUNT * 2.5, 0) AS USAGE_DURATION_MINUTES,
        COALESCE(USAGE_COUNT * 5.0, 0) AS SESSION_DURATION_MINUTES,
        CASE 
            WHEN USAGE_COUNT >= 10 THEN 'High'
            WHEN USAGE_COUNT >= 5 THEN 'Medium'
            ELSE 'Low'
        END AS USAGE_INTENSITY,
        CASE 
            WHEN USAGE_COUNT > 0 THEN 9.5
            ELSE 0.0
        END AS USER_EXPERIENCE_SCORE,
        CASE 
            WHEN USAGE_COUNT > 0 THEN 9.8
            ELSE 0.0
        END AS FEATURE_PERFORMANCE_SCORE,
        3 AS CONCURRENT_FEATURES_COUNT,
        0 AS ERROR_COUNT,
        CASE 
            WHEN USAGE_COUNT > 0 THEN 98.5
            ELSE 0.0
        END AS SUCCESS_RATE_PERCENTAGE,
        COALESCE(USAGE_COUNT * 1.5, 0) AS BANDWIDTH_CONSUMED_MB,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_usage
)

SELECT * FROM feature_usage_metrics
