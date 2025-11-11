{{
  config(
    materialized='table',
    cluster_by=['DATE_KEY', 'FEATURE_KEY'],
    tags=['fact', 'gold']
  )
}}

-- Feature Usage Fact Table
WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE COALESCE(fu.VALIDATION_STATUS, '') = 'PASSED'
      AND fu.USAGE_ID IS NOT NULL
      AND fu.FEATURE_NAME IS NOT NULL
),

meeting_context AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.DURATION_MINUTES
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE COALESCE(sm.VALIDATION_STATUS, '') = 'PASSED'
),

fact_data AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY fub.USAGE_ID) AS FEATURE_USAGE_ID,
        -- Foreign Keys
        dd.DATE_KEY,
        df.FEATURE_KEY,
        COALESCE(du.USER_KEY, 'UNKNOWN') AS USER_KEY,
        COALESCE(dm.MEETING_KEY, 'UNKNOWN') AS MEETING_KEY,
        -- Fact Measures
        fub.USAGE_DATE,
        fub.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        COALESCE(fub.FEATURE_NAME, 'Unknown') AS FEATURE_NAME,
        COALESCE(fub.USAGE_COUNT, 0) AS USAGE_COUNT,
        COALESCE(mc.DURATION_MINUTES, 0) AS USAGE_DURATION_MINUTES,
        COALESCE(mc.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
        CASE 
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 10 THEN 5.0
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 5 THEN 4.0
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 3 THEN 3.0
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 1 THEN 2.0
            ELSE 1.0
        END AS FEATURE_ADOPTION_SCORE,
        CASE 
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 5 AND COALESCE(mc.DURATION_MINUTES, 0) >= 30 THEN 5.0
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 3 AND COALESCE(mc.DURATION_MINUTES, 0) >= 15 THEN 4.0
            WHEN COALESCE(fub.USAGE_COUNT, 0) >= 1 THEN 3.0
            ELSE 2.0
        END AS USER_EXPERIENCE_RATING,
        CASE 
            WHEN COALESCE(fub.USAGE_COUNT, 0) > 0 THEN 5.0
            ELSE 1.0
        END AS FEATURE_PERFORMANCE_SCORE,
        1 AS CONCURRENT_FEATURES_COUNT, -- Default value
        CASE 
            WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 60 THEN 'Extended Session'
            WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 30 THEN 'Standard Session'
            WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 15 THEN 'Short Session'
            WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 5 THEN 'Brief Session'
            ELSE 'Quick Access'
        END AS USAGE_CONTEXT,
        'Desktop' AS DEVICE_TYPE, -- Default value
        'Latest' AS PLATFORM_VERSION, -- Default value
        0 AS ERROR_COUNT, -- Default value
        CASE 
            WHEN COALESCE(fub.USAGE_COUNT, 0) > 0 THEN 100.0
            ELSE 0.0
        END AS SUCCESS_RATE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(fub.SOURCE_SYSTEM, 'SILVER_ETL') AS SOURCE_SYSTEM
    FROM feature_usage_base fub
    LEFT JOIN {{ ref('dim_date') }} dd ON fub.USAGE_DATE = dd.DATE_KEY
    LEFT JOIN {{ ref('dim_feature') }} df ON {{ dbt_utils.generate_surrogate_key(['fub.FEATURE_NAME']) }} = df.FEATURE_KEY
    LEFT JOIN meeting_context mc ON fub.MEETING_ID = mc.MEETING_ID
    LEFT JOIN {{ ref('dim_user') }} du ON mc.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN {{ ref('dim_meeting') }} dm ON {{ dbt_utils.generate_surrogate_key(['fub.MEETING_ID']) }} = dm.MEETING_KEY
    WHERE dd.DATE_KEY IS NOT NULL
      AND df.FEATURE_KEY IS NOT NULL
)

SELECT * FROM fact_data
