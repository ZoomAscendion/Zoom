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
        COALESCE(fu.USAGE_COUNT, 0) AS USAGE_COUNT,
        COALESCE(fu.USAGE_DATE, CURRENT_DATE()) AS USAGE_DATE,
        fu.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
      AND fu.FEATURE_NAME IS NOT NULL
      AND TRIM(fu.FEATURE_NAME) != ''
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY fub.USAGE_ID) AS FEATURE_USAGE_ID,
    COALESCE(dd.DATE_ID, 1) AS DATE_ID,
    COALESCE(df.FEATURE_ID, 1) AS FEATURE_ID,
    COALESCE(du.USER_DIM_ID, 1) AS USER_DIM_ID,
    fub.MEETING_ID,
    fub.USAGE_DATE,
    fub.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
    fub.FEATURE_NAME,
    fub.USAGE_COUNT,
    30 AS USAGE_DURATION_MINUTES, -- Default duration
    30 AS SESSION_DURATION_MINUTES, -- Default session duration
    CASE 
        WHEN fub.USAGE_COUNT >= 10 THEN 5.0
        WHEN fub.USAGE_COUNT >= 5 THEN 4.0
        WHEN fub.USAGE_COUNT >= 3 THEN 3.0
        WHEN fub.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END AS FEATURE_ADOPTION_SCORE,
    CASE 
        WHEN fub.USAGE_COUNT >= 10 THEN 5.0
        WHEN fub.USAGE_COUNT >= 5 THEN 4.0
        WHEN fub.USAGE_COUNT >= 3 THEN 3.0
        WHEN fub.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END AS USER_EXPERIENCE_RATING,
    4.0 AS FEATURE_PERFORMANCE_SCORE, -- Default performance score
    1 AS CONCURRENT_FEATURES_COUNT,
    'Standard Session' AS USAGE_CONTEXT,
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
LEFT JOIN {{ ref('go_dim_user') }} du ON du.USER_DIM_ID = 1 -- Default user for now
