{{ config(
    materialized='table'
) }}

-- Feature usage fact table with adoption and performance metrics
-- Tracks detailed feature usage patterns and user engagement

WITH source_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND USAGE_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
),

source_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        DURATION_MINUTES
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

feature_usage_fact AS (
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
        COALESCE(sm.DURATION_MINUTES, 0) AS USAGE_DURATION_MINUTES,
        COALESCE(sm.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
        CASE 
            WHEN fu.USAGE_COUNT >= 10 THEN 5.0
            WHEN fu.USAGE_COUNT >= 5 THEN 4.0
            WHEN fu.USAGE_COUNT >= 3 THEN 3.0
            WHEN fu.USAGE_COUNT >= 1 THEN 2.0
            ELSE 1.0
        END AS FEATURE_ADOPTION_SCORE,
        4.5 AS USER_EXPERIENCE_RATING,
        4.5 AS FEATURE_PERFORMANCE_SCORE,
        1 AS CONCURRENT_FEATURES_COUNT,
        CASE 
            WHEN COALESCE(sm.DURATION_MINUTES, 0) >= 60 THEN 'Extended Session'
            WHEN COALESCE(sm.DURATION_MINUTES, 0) >= 30 THEN 'Standard Session'
            WHEN COALESCE(sm.DURATION_MINUTES, 0) >= 15 THEN 'Short Session'
            WHEN COALESCE(sm.DURATION_MINUTES, 0) >= 5 THEN 'Brief Session'
            ELSE 'Quick Access'
        END AS USAGE_CONTEXT,
        'Desktop' AS DEVICE_TYPE,
        'v1.0' AS PLATFORM_VERSION,
        0 AS ERROR_COUNT,
        100.0 AS SUCCESS_RATE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        fu.SOURCE_SYSTEM
    FROM source_feature_usage fu
    LEFT JOIN {{ ref('go_dim_date') }} dd ON fu.USAGE_DATE = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_feature') }} df ON fu.FEATURE_NAME = df.FEATURE_NAME
    LEFT JOIN source_meetings sm ON fu.MEETING_ID = sm.MEETING_ID
    LEFT JOIN {{ ref('go_dim_user') }} du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM feature_usage_fact
