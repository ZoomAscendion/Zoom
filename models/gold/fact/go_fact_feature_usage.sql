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
    FROM DB_POC_ZOOM.SILVER.SI_FEATURE_USAGE
    WHERE VALIDATION_STATUS = 'PASSED'
      AND USAGE_ID IS NOT NULL
      AND FEATURE_NAME IS NOT NULL
),

feature_usage_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY fu.USAGE_ID) AS FEATURE_USAGE_ID,
        1 AS DATE_ID,
        1 AS FEATURE_ID,
        1 AS USER_DIM_ID,
        fu.MEETING_ID,
        fu.USAGE_DATE,
        fu.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        30 AS USAGE_DURATION_MINUTES,
        30 AS SESSION_DURATION_MINUTES,
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
        'Standard Session' AS USAGE_CONTEXT,
        'Desktop' AS DEVICE_TYPE,
        'v1.0' AS PLATFORM_VERSION,
        0 AS ERROR_COUNT,
        100.0 AS SUCCESS_RATE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        fu.SOURCE_SYSTEM
    FROM source_feature_usage fu
)

SELECT * FROM feature_usage_fact
