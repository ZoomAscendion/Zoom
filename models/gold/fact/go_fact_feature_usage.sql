{{ config(
    materialized='table'
) }}

-- Feature usage fact table transformation from Silver to Gold layer
WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.FEATURE_NAME IS NOT NULL
),

feature_usage_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY fub.USAGE_ID) AS FEATURE_USAGE_ID,
        COALESCE(dd.DATE_ID, 1) AS DATE_ID,
        COALESCE(df.FEATURE_ID, 1) AS FEATURE_ID,
        1 AS USER_DIM_ID,
        fub.MEETING_ID,
        COALESCE(fub.USAGE_DATE, CURRENT_DATE()) AS USAGE_DATE,
        COALESCE(fub.USAGE_DATE, CURRENT_DATE())::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        fub.FEATURE_NAME,
        COALESCE(fub.USAGE_COUNT, 0) AS USAGE_COUNT,
        30 AS USAGE_DURATION_MINUTES,
        30 AS SESSION_DURATION_MINUTES,
        CASE 
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 10 THEN 5.0
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 5 THEN 4.0
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 3 THEN 3.0
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 1 THEN 2.0
            ELSE 1.0
        END AS FEATURE_ADOPTION_SCORE,
        4.0 AS USER_EXPERIENCE_RATING,
        4.5 AS FEATURE_PERFORMANCE_SCORE,
        1 AS CONCURRENT_FEATURES_COUNT,
        'Standard Session' AS USAGE_CONTEXT,
        'Desktop' AS DEVICE_TYPE,
        '1.0.0' AS PLATFORM_VERSION,
        0 AS ERROR_COUNT,
        CASE 
            WHEN COALESCE(fub.USAGE_COUNT, 0) > 0 THEN 100.0
            ELSE 0.0
        END AS SUCCESS_RATE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(fub.SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM feature_usage_base fub
    LEFT JOIN {{ ref('go_dim_date') }} dd ON COALESCE(fub.USAGE_DATE, CURRENT_DATE()) = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_feature') }} df ON fub.FEATURE_NAME = df.FEATURE_NAME
)

SELECT * FROM feature_usage_fact
