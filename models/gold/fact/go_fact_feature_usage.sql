{{ config(
    materialized='table',
    unique_key='FEATURE_USAGE_ID'
) }}

-- Feature usage fact table with adoption and performance metrics

WITH source_feature_usage AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM,
        m.HOST_ID,
        m.DURATION_MINUTES,
        m.START_TIME
    FROM {{ source('gold_existing', 'si_feature_usage') }} fu
    LEFT JOIN {{ source('gold_existing', 'si_meetings') }} m 
        ON fu.MEETING_ID = m.MEETING_ID
    WHERE fu.VALIDATION_STATUS = 'PASSED'
      AND fu.DATA_QUALITY_SCORE >= 70
),

feature_usage_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY sfu.USAGE_ID) AS FEATURE_USAGE_ID,
        dd.DATE_ID,
        df.FEATURE_ID,
        du.USER_DIM_ID,
        sfu.MEETING_ID,
        sfu.USAGE_DATE,
        sfu.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        sfu.FEATURE_NAME,
        sfu.USAGE_COUNT,
        COALESCE(sfu.DURATION_MINUTES, 0) AS USAGE_DURATION_MINUTES,
        COALESCE(sfu.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
        -- Feature adoption score based on usage frequency
        CASE 
            WHEN sfu.USAGE_COUNT >= 20 THEN 5.0
            WHEN sfu.USAGE_COUNT >= 10 THEN 4.0
            WHEN sfu.USAGE_COUNT >= 5 THEN 3.0
            WHEN sfu.USAGE_COUNT >= 1 THEN 2.0
            ELSE 1.0
        END AS FEATURE_ADOPTION_SCORE,
        -- User experience rating based on usage patterns
        CASE 
            WHEN sfu.USAGE_COUNT >= 10 AND sfu.DURATION_MINUTES >= 30 THEN 5.0
            WHEN sfu.USAGE_COUNT >= 5 AND sfu.DURATION_MINUTES >= 15 THEN 4.0
            WHEN sfu.USAGE_COUNT >= 3 AND sfu.DURATION_MINUTES >= 10 THEN 3.0
            WHEN sfu.USAGE_COUNT >= 1 THEN 2.0
            ELSE 1.0
        END AS USER_EXPERIENCE_RATING,
        -- Feature performance score (simplified)
        CASE 
            WHEN sfu.USAGE_COUNT > 0 THEN 4.5
            ELSE 1.0
        END AS FEATURE_PERFORMANCE_SCORE,
        1 AS CONCURRENT_FEATURES_COUNT, -- Simplified for now
        CASE 
            WHEN sfu.DURATION_MINUTES >= 60 THEN 'Extended Session'
            WHEN sfu.DURATION_MINUTES >= 30 THEN 'Standard Session'
            WHEN sfu.DURATION_MINUTES >= 15 THEN 'Short Session'
            WHEN sfu.DURATION_MINUTES >= 5 THEN 'Brief Session'
            ELSE 'Quick Access'
        END AS USAGE_CONTEXT,
        'Desktop' AS DEVICE_TYPE, -- Default value
        'Latest' AS PLATFORM_VERSION, -- Default value
        0 AS ERROR_COUNT, -- Default value
        CASE 
            WHEN sfu.USAGE_COUNT > 0 THEN 100.0
            ELSE 0.0
        END AS SUCCESS_RATE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        sfu.SOURCE_SYSTEM
    FROM source_feature_usage sfu
    LEFT JOIN {{ ref('go_dim_date') }} dd 
        ON sfu.USAGE_DATE = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_feature') }} df 
        ON UPPER(TRIM(sfu.FEATURE_NAME)) = UPPER(TRIM(df.FEATURE_NAME))
    LEFT JOIN {{ ref('go_dim_user') }} du 
        ON sfu.HOST_ID = du.USER_ID 
        AND du.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM feature_usage_fact
