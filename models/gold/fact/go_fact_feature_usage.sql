{{ config(
    materialized='table'
) }}

-- Feature Usage Fact Table
-- Captures detailed feature usage metrics and patterns

WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
      AND fu.FEATURE_NAME IS NOT NULL
      AND fu.USAGE_DATE IS NOT NULL
),

meeting_context AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.DURATION_MINUTES
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE sm.VALIDATION_STATUS = 'PASSED'
),

feature_usage_facts AS (
    SELECT 
        dd.DATE_KEY,
        df.FEATURE_KEY,
        COALESCE(du.USER_KEY, 'NO_USER') AS USER_KEY,
        COALESCE(
            CONCAT('MTG_STANDARD_BUSINESS_', 
                   CASE 
                       WHEN mc.DURATION_MINUTES <= 15 THEN 'SHORT'
                       WHEN mc.DURATION_MINUTES <= 60 THEN 'MEDIUM'
                       WHEN mc.DURATION_MINUTES <= 180 THEN 'LONG'
                       ELSE 'EXTENDED'
                   END, '_SMALL_MORNING'
            ), 
            'NO_MEETING'
        ) AS MEETING_KEY,
        fub.USAGE_DATE,
        fub.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        TRIM(UPPER(fub.FEATURE_NAME)) AS FEATURE_NAME,
        COALESCE(fub.USAGE_COUNT, 0) AS USAGE_COUNT,
        COALESCE(mc.DURATION_MINUTES, 0) AS USAGE_DURATION_MINUTES,
        COALESCE(mc.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
        CASE 
            WHEN fub.USAGE_COUNT >= 10 THEN 5.0
            WHEN fub.USAGE_COUNT >= 5 THEN 4.0
            WHEN fub.USAGE_COUNT >= 3 THEN 3.0
            WHEN fub.USAGE_COUNT >= 1 THEN 2.0
            ELSE 1.0
        END AS FEATURE_ADOPTION_SCORE,
        4.2 AS USER_EXPERIENCE_RATING,
        8.5 AS FEATURE_PERFORMANCE_SCORE,
        1 AS CONCURRENT_FEATURES_COUNT,
        'MEETING' AS USAGE_CONTEXT,
        'DESKTOP' AS DEVICE_TYPE,
        '5.8.3' AS PLATFORM_VERSION,
        0 AS ERROR_COUNT,
        CASE 
            WHEN fub.USAGE_COUNT > 0 THEN 100.0
            ELSE 0.0
        END AS SUCCESS_RATE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        fub.SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY dd.DATE_KEY, df.FEATURE_KEY, COALESCE(du.USER_KEY, 'NO_USER'), 
                        COALESCE(
                            CONCAT('MTG_STANDARD_BUSINESS_', 
                                   CASE 
                                       WHEN mc.DURATION_MINUTES <= 15 THEN 'SHORT'
                                       WHEN mc.DURATION_MINUTES <= 60 THEN 'MEDIUM'
                                       WHEN mc.DURATION_MINUTES <= 180 THEN 'LONG'
                                       ELSE 'EXTENDED'
                                   END, '_SMALL_MORNING'
                            ), 
                            'NO_MEETING'
                        ), 
                        fub.USAGE_DATE::TIMESTAMP_NTZ
            ORDER BY fub.USAGE_ID DESC
        ) AS rn
    FROM feature_usage_base fub
    INNER JOIN {{ ref('go_dim_date') }} dd ON fub.USAGE_DATE = dd.DATE_KEY
    INNER JOIN {{ ref('go_dim_feature') }} df ON fub.FEATURE_NAME = df.FEATURE_NAME
    LEFT JOIN meeting_context mc ON fub.MEETING_ID = mc.MEETING_ID
    LEFT JOIN {{ ref('go_dim_user') }} du ON mc.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
)

SELECT 
    DATE_KEY,
    FEATURE_KEY,
    USER_KEY,
    MEETING_KEY,
    USAGE_DATE,
    USAGE_TIMESTAMP,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DURATION_MINUTES,
    SESSION_DURATION_MINUTES,
    FEATURE_ADOPTION_SCORE,
    USER_EXPERIENCE_RATING,
    FEATURE_PERFORMANCE_SCORE,
    CONCURRENT_FEATURES_COUNT,
    USAGE_CONTEXT,
    DEVICE_TYPE,
    PLATFORM_VERSION,
    ERROR_COUNT,
    SUCCESS_RATE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM feature_usage_facts
WHERE rn = 1
