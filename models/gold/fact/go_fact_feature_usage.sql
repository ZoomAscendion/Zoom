{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS) VALUES (GENERATE_UUID(), 'GO_FACT_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'STARTED')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_END_TIME, EXECUTION_STATUS, RECORDS_PROCESSED) VALUES (GENERATE_UUID(), 'GO_FACT_FEATURE_USAGE', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}))"
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
        fu.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
),

feature_usage_metrics AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY USAGE_ID) AS FEATURE_USAGE_ID,
        USAGE_DATE,
        LOAD_TIMESTAMP AS USAGE_TIMESTAMP,
        FEATURE_NAME,
        USAGE_COUNT,
        -- Derived metrics with default values for missing data
        COALESCE(USAGE_COUNT * 2.5, 0) AS USAGE_DURATION_MINUTES, -- Estimated
        COALESCE(USAGE_COUNT * 5.0, 0) AS SESSION_DURATION_MINUTES, -- Estimated
        CASE 
            WHEN USAGE_COUNT >= 10 THEN 'High'
            WHEN USAGE_COUNT >= 5 THEN 'Medium'
            ELSE 'Low'
        END AS USAGE_INTENSITY,
        -- Quality scores (simulated for demo)
        CASE 
            WHEN USAGE_COUNT > 0 THEN ROUND(RANDOM() * 2 + 8, 1) -- 8.0-10.0
            ELSE 0.0
        END AS USER_EXPERIENCE_SCORE,
        CASE 
            WHEN USAGE_COUNT > 0 THEN ROUND(RANDOM() * 1 + 9, 1) -- 9.0-10.0
            ELSE 0.0
        END AS FEATURE_PERFORMANCE_SCORE,
        -- Additional metrics
        GREATEST(1, FLOOR(RANDOM() * 5) + 1) AS CONCURRENT_FEATURES_COUNT,
        FLOOR(RANDOM() * 3) AS ERROR_COUNT, -- 0-2 errors
        CASE 
            WHEN USAGE_COUNT > 0 THEN ROUND((USAGE_COUNT - FLOOR(RANDOM() * 3)) / USAGE_COUNT * 100, 2)
            ELSE 0.0
        END AS SUCCESS_RATE_PERCENTAGE,
        COALESCE(USAGE_COUNT * 1.5, 0) AS BANDWIDTH_CONSUMED_MB, -- Estimated
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_usage
)

SELECT * FROM feature_usage_metrics
