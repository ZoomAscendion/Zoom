{{ config(
    materialized='table',
    tags=['fact', 'gold']
) }}

-- Gold Fact: Feature Usage Fact Table
-- Detailed feature usage metrics and patterns

WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.USAGE_DATE,
        COALESCE(fu.FEATURE_NAME, 'Unknown Feature') AS FEATURE_NAME,
        COALESCE(fu.USAGE_COUNT, 0) AS USAGE_COUNT,
        COALESCE(fu.SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE COALESCE(fu.VALIDATION_STATUS, 'UNKNOWN') != 'FAILED'
      AND fu.USAGE_ID IS NOT NULL
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY fu.USAGE_ID) AS FEATURE_USAGE_ID,
    COALESCE(dd.DATE_ID, 1) AS DATE_ID,
    COALESCE(df.FEATURE_ID, 1) AS FEATURE_ID,
    COALESCE(du.USER_DIM_ID, 1) AS USER_DIM_ID,
    fu.MEETING_ID,
    fu.USAGE_DATE,
    fu.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
    fu.FEATURE_NAME,
    fu.USAGE_COUNT,
    0 AS USAGE_DURATION_MINUTES,
    0 AS SESSION_DURATION_MINUTES,
    CASE 
        WHEN fu.USAGE_COUNT >= 10 THEN 5.0
        WHEN fu.USAGE_COUNT >= 5 THEN 4.0
        WHEN fu.USAGE_COUNT >= 3 THEN 3.0
        WHEN fu.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END AS FEATURE_ADOPTION_SCORE,
    CASE 
        WHEN fu.USAGE_COUNT >= 10 THEN 5.0
        WHEN fu.USAGE_COUNT >= 5 THEN 4.0
        WHEN fu.USAGE_COUNT >= 3 THEN 3.0
        WHEN fu.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END AS USER_EXPERIENCE_RATING,
    CASE 
        WHEN fu.USAGE_COUNT > 0 THEN 5.0
        ELSE 1.0
    END AS FEATURE_PERFORMANCE_SCORE,
    1 AS CONCURRENT_FEATURES_COUNT,
    'Standard Session' AS USAGE_CONTEXT,
    'Desktop' AS DEVICE_TYPE,
    '1.0' AS PLATFORM_VERSION,
    0 AS ERROR_COUNT,
    CASE 
        WHEN fu.USAGE_COUNT > 0 THEN 100.0
        ELSE 0.0
    END AS SUCCESS_RATE,
    CURRENT_DATE AS LOAD_DATE,
    CURRENT_DATE AS UPDATE_DATE,
    fu.SOURCE_SYSTEM
FROM feature_usage_base fu
LEFT JOIN {{ ref('go_dim_date') }} dd ON fu.USAGE_DATE = dd.DATE_VALUE
LEFT JOIN {{ ref('go_dim_feature') }} df ON fu.FEATURE_NAME = df.FEATURE_NAME
LEFT JOIN {{ source('silver', 'si_meetings') }} sm ON fu.MEETING_ID = sm.MEETING_ID
LEFT JOIN {{ ref('go_dim_user') }} du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
