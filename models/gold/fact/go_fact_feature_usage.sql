{{ config(
    materialized='table'
) }}

-- Feature Usage Fact Table
-- Captures detailed feature usage metrics and patterns

WITH source_features AS (
    SELECT *
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

source_meetings AS (
    SELECT *
    FROM {{ source('silver', 'si_meetings') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
),

unique_features AS (
    SELECT DISTINCT 
        FEATURE_NAME, 
        FEATURE_KEY,
        ROW_NUMBER() OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC) AS rn
    FROM {{ ref('go_dim_feature') }}
),

unique_users AS (
    SELECT DISTINCT 
        USER_ID, 
        USER_KEY,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) AS rn
    FROM {{ ref('go_dim_user') }}
    WHERE IS_CURRENT_RECORD = TRUE
),

unique_meetings AS (
    SELECT DISTINCT 
        MEETING_KEY,
        ROW_NUMBER() OVER (PARTITION BY MEETING_KEY ORDER BY UPDATE_DATE DESC) AS rn
    FROM {{ ref('go_dim_meeting') }}
),

feature_usage_transformations AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COALESCE(fu.USAGE_ID, 'UNKNOWN_USAGE')) AS FEATURE_USAGE_ID,
        -- Foreign Key Columns for BI Integration
        COALESCE(dd.DATE_KEY, CURRENT_DATE()) AS DATE_KEY,
        COALESCE(df.FEATURE_KEY, 'UNKNOWN_FEATURE') AS FEATURE_KEY,
        COALESCE(du.USER_KEY, 'UNKNOWN_USER') AS USER_KEY,
        COALESCE(dm.MEETING_KEY, COALESCE(fu.MEETING_ID, 'UNKNOWN_MEETING')) AS MEETING_KEY,
        -- Fact Measures
        COALESCE(fu.USAGE_DATE, CURRENT_DATE()) AS USAGE_DATE,
        COALESCE(fu.USAGE_DATE, CURRENT_DATE())::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        COALESCE(fu.FEATURE_NAME, 'Unknown Feature') AS FEATURE_NAME,
        COALESCE(fu.USAGE_COUNT, 0) AS USAGE_COUNT,
        COALESCE(sm.DURATION_MINUTES, 30) AS USAGE_DURATION_MINUTES,
        COALESCE(sm.DURATION_MINUTES, 30) AS SESSION_DURATION_MINUTES,
        CASE 
            WHEN COALESCE(fu.USAGE_COUNT, 0) >= 10 THEN 5.0
            WHEN COALESCE(fu.USAGE_COUNT, 0) >= 5 THEN 4.0
            WHEN COALESCE(fu.USAGE_COUNT, 0) >= 3 THEN 3.0
            WHEN COALESCE(fu.USAGE_COUNT, 0) >= 1 THEN 2.0
            ELSE 1.0
        END AS FEATURE_ADOPTION_SCORE,
        8.5 AS USER_EXPERIENCE_RATING,
        9.0 AS FEATURE_PERFORMANCE_SCORE,
        1 AS CONCURRENT_FEATURES_COUNT,
        'Meeting' AS USAGE_CONTEXT,
        'Desktop' AS DEVICE_TYPE,
        '5.12.0' AS PLATFORM_VERSION,
        0 AS ERROR_COUNT,
        CASE 
            WHEN COALESCE(fu.USAGE_COUNT, 0) > 0 THEN 100.0
            ELSE 0.0
        END AS SUCCESS_RATE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SILVER_TO_GOLD_ETL' AS SOURCE_SYSTEM
    FROM source_features fu
    LEFT JOIN {{ ref('go_dim_date') }} dd ON COALESCE(fu.USAGE_DATE, CURRENT_DATE()) = dd.DATE_KEY
    LEFT JOIN unique_features df ON COALESCE(fu.FEATURE_NAME, 'Unknown Feature') = df.FEATURE_NAME AND df.rn = 1
    LEFT JOIN source_meetings sm ON COALESCE(fu.MEETING_ID, 'UNKNOWN_MEETING') = sm.MEETING_ID
    LEFT JOIN unique_users du ON COALESCE(sm.HOST_ID, 'UNKNOWN_HOST') = du.USER_ID AND du.rn = 1
    LEFT JOIN unique_meetings dm ON COALESCE(fu.MEETING_ID, 'UNKNOWN_MEETING') = dm.MEETING_KEY AND dm.rn = 1
)

SELECT 
    FEATURE_USAGE_ID,
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
FROM feature_usage_transformations
