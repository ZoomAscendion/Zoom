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
        fu.SOURCE_SYSTEM,
        m.HOST_ID,
        m.DURATION_MINUTES
    FROM {{ source('silver', 'si_feature_usage') }} fu
    LEFT JOIN {{ source('silver', 'si_meetings') }} m ON fu.MEETING_ID = m.MEETING_ID
    WHERE fu.VALIDATION_STATUS = 'PASSED'
      AND fu.FEATURE_NAME IS NOT NULL
),

feature_usage_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY fub.USAGE_ID) AS FEATURE_USAGE_ID,
        dd.DATE_ID AS DATE_ID,
        df.FEATURE_ID AS FEATURE_ID,
        du.USER_DIM_ID AS USER_DIM_ID,
        fub.MEETING_ID,
        fub.USAGE_DATE,
        fub.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        fub.FEATURE_NAME,
        fub.USAGE_COUNT,
        COALESCE(fub.DURATION_MINUTES, 0) AS USAGE_DURATION_MINUTES,
        COALESCE(fub.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
        CASE 
            WHEN fub.USAGE_COUNT >= 10 THEN 5.0
            WHEN fub.USAGE_COUNT >= 5 THEN 4.0
            WHEN fub.USAGE_COUNT >= 3 THEN 3.0
            WHEN fub.USAGE_COUNT >= 1 THEN 2.0
            ELSE 1.0
        END AS FEATURE_ADOPTION_SCORE,
        4.0 AS USER_EXPERIENCE_RATING,
        4.5 AS FEATURE_PERFORMANCE_SCORE,
        1 AS CONCURRENT_FEATURES_COUNT,
        CASE 
            WHEN COALESCE(fub.DURATION_MINUTES, 0) >= 60 THEN 'Extended Session'
            WHEN COALESCE(fub.DURATION_MINUTES, 0) >= 30 THEN 'Standard Session'
            WHEN COALESCE(fub.DURATION_MINUTES, 0) >= 15 THEN 'Short Session'
            WHEN COALESCE(fub.DURATION_MINUTES, 0) >= 5 THEN 'Brief Session'
            ELSE 'Quick Access'
        END AS USAGE_CONTEXT,
        'Desktop' AS DEVICE_TYPE,
        '1.0.0' AS PLATFORM_VERSION,
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
    LEFT JOIN {{ ref('go_dim_user') }} du ON fub.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM feature_usage_fact
