{{ config(
    materialized='table',
    cluster_by=['USAGE_DATE', 'FEATURE_ID']
) }}

WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        fu.SOURCE_SYSTEM
    FROM {{ ref('si_feature_usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
      AND fu.FEATURE_NAME IS NOT NULL
),

meeting_context AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.DURATION_MINUTES AS SESSION_DURATION_MINUTES
    FROM {{ ref('si_meetings') }} sm
    WHERE sm.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    dd.DATE_ID,
    df.FEATURE_ID,
    du.USER_DIM_ID,
    fub.MEETING_ID,
    fub.USAGE_DATE,
    fub.USAGE_TIMESTAMP,
    fub.FEATURE_NAME,
    fub.USAGE_COUNT,
    0 AS USAGE_DURATION_MINUTES,
    COALESCE(mc.SESSION_DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
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
    CASE 
        WHEN fub.USAGE_COUNT > 0 THEN 5.0
        ELSE 1.0
    END AS FEATURE_PERFORMANCE_SCORE,
    1 AS CONCURRENT_FEATURES_COUNT,
    CASE 
        WHEN COALESCE(mc.SESSION_DURATION_MINUTES, 0) >= 60 THEN 'Extended Session'
        WHEN COALESCE(mc.SESSION_DURATION_MINUTES, 0) >= 30 THEN 'Standard Session'
        WHEN COALESCE(mc.SESSION_DURATION_MINUTES, 0) >= 15 THEN 'Short Session'
        ELSE 'Quick Access'
    END AS USAGE_CONTEXT,
    'Desktop' AS DEVICE_TYPE,
    'Latest' AS PLATFORM_VERSION,
    0 AS ERROR_COUNT,
    CASE 
        WHEN fub.USAGE_COUNT > 0 THEN 100.0
        ELSE 0.0
    END AS SUCCESS_RATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    fub.SOURCE_SYSTEM
FROM feature_usage_base fub
LEFT JOIN {{ ref('go_dim_date') }} dd ON fub.USAGE_DATE = dd.DATE_VALUE
LEFT JOIN {{ ref('go_dim_feature') }} df ON fub.FEATURE_NAME = df.FEATURE_NAME
LEFT JOIN meeting_context mc ON fub.MEETING_ID = mc.MEETING_ID
LEFT JOIN {{ ref('go_dim_user') }} du ON mc.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
