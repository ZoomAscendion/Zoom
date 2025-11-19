{{ config(
    materialized='table'
) }}

-- Feature Usage Fact Table
-- Fact table capturing detailed feature usage metrics and patterns

WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM,
        COALESCE(fu.USAGE_DATE::TIMESTAMP_NTZ, CURRENT_TIMESTAMP()) AS USAGE_TIMESTAMP
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
      AND fu.FEATURE_NAME IS NOT NULL
),

meeting_context AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.DURATION_MINUTES,
        sm.DATA_QUALITY_SCORE
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE sm.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY fub.USAGE_ID) AS FEATURE_USAGE_ID,
    dd.DATE_ID,
    df.FEATURE_ID,
    du.USER_DIM_ID,
    fub.MEETING_ID,
    fub.USAGE_DATE,
    fub.USAGE_TIMESTAMP,
    fub.FEATURE_NAME,
    fub.USAGE_COUNT,
    COALESCE(mc.DURATION_MINUTES, 0) AS USAGE_DURATION_MINUTES,
    COALESCE(mc.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
    CASE 
        WHEN fub.USAGE_COUNT >= 10 THEN 5.0
        WHEN fub.USAGE_COUNT >= 5 THEN 4.0
        WHEN fub.USAGE_COUNT >= 3 THEN 3.0
        WHEN fub.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END AS FEATURE_ADOPTION_SCORE,
    CASE 
        WHEN fub.USAGE_COUNT >= 10 AND COALESCE(mc.DATA_QUALITY_SCORE, 0) >= 90 THEN 5.0
        WHEN fub.USAGE_COUNT >= 5 AND COALESCE(mc.DATA_QUALITY_SCORE, 0) >= 80 THEN 4.0
        WHEN fub.USAGE_COUNT >= 3 AND COALESCE(mc.DATA_QUALITY_SCORE, 0) >= 70 THEN 3.0
        WHEN fub.USAGE_COUNT >= 1 AND COALESCE(mc.DATA_QUALITY_SCORE, 0) >= 60 THEN 2.0
        ELSE 1.0
    END AS USER_EXPERIENCE_RATING,
    CASE 
        WHEN COALESCE(mc.DATA_QUALITY_SCORE, 0) >= 95 THEN 5.0
        WHEN COALESCE(mc.DATA_QUALITY_SCORE, 0) >= 85 THEN 4.0
        WHEN COALESCE(mc.DATA_QUALITY_SCORE, 0) >= 70 THEN 3.0
        WHEN COALESCE(mc.DATA_QUALITY_SCORE, 0) >= 50 THEN 2.0
        ELSE 1.0
    END AS FEATURE_PERFORMANCE_SCORE,
    1 AS CONCURRENT_FEATURES_COUNT,
    CASE 
        WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 60 THEN 'Extended Session'
        WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 30 THEN 'Standard Session'
        WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 15 THEN 'Short Session'
        WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 5 THEN 'Brief Session'
        ELSE 'Quick Access'
    END AS USAGE_CONTEXT,
    'Desktop' AS DEVICE_TYPE,
    'Latest' AS PLATFORM_VERSION,
    0 AS ERROR_COUNT,
    CASE 
        WHEN fub.USAGE_COUNT > 0 THEN 100.0
        ELSE 0.0
    END AS SUCCESS_RATE,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    fub.SOURCE_SYSTEM
FROM feature_usage_base fub
LEFT JOIN {{ ref('go_dim_date') }} dd ON fub.USAGE_DATE = dd.DATE_VALUE
LEFT JOIN {{ ref('go_dim_feature') }} df ON fub.FEATURE_NAME = df.FEATURE_NAME
LEFT JOIN meeting_context mc ON fub.MEETING_ID = mc.MEETING_ID
LEFT JOIN {{ ref('go_dim_user') }} du ON mc.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
