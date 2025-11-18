{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('{{ invocation_id }}_fact_feature', 'go_fact_feature_usage', CURRENT_TIMESTAMP(), 'RUNNING', 'si_feature_usage', 'go_fact_feature_usage', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_ETL')",
    post_hook="UPDATE {{ ref('go_process_audit') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), UPDATE_DATE = CURRENT_DATE() WHERE AUDIT_LOG_ID = '{{ invocation_id }}_fact_feature'"
) }}

-- Feature usage fact table with adoption and performance metrics

WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM,
        sm.HOST_ID,
        sm.DURATION_MINUTES AS SESSION_DURATION_MINUTES
    FROM {{ source('silver', 'si_feature_usage') }} fu
    LEFT JOIN {{ source('silver', 'si_meetings') }} sm ON fu.MEETING_ID = sm.MEETING_ID
    WHERE fu.VALIDATION_STATUS = 'PASSED'
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY fub.USAGE_ID) AS FEATURE_USAGE_ID,
    dd.DATE_ID,
    df.FEATURE_ID,
    du.USER_DIM_ID,
    fub.MEETING_ID,
    fub.USAGE_DATE,
    fub.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
    fub.FEATURE_NAME,
    fub.USAGE_COUNT,
    COALESCE(fub.SESSION_DURATION_MINUTES, 0) AS USAGE_DURATION_MINUTES,
    COALESCE(fub.SESSION_DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
    CASE 
        WHEN fub.USAGE_COUNT >= 10 THEN 5.0
        WHEN fub.USAGE_COUNT >= 5 THEN 4.0
        WHEN fub.USAGE_COUNT >= 3 THEN 3.0
        WHEN fub.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END AS FEATURE_ADOPTION_SCORE,
    4.5 AS USER_EXPERIENCE_RATING,
    CASE 
        WHEN fub.USAGE_COUNT > 0 THEN 5.0
        ELSE 1.0
    END AS FEATURE_PERFORMANCE_SCORE,
    1 AS CONCURRENT_FEATURES_COUNT,
    CASE 
        WHEN COALESCE(fub.SESSION_DURATION_MINUTES, 0) >= 60 THEN 'Extended Session'
        WHEN COALESCE(fub.SESSION_DURATION_MINUTES, 0) >= 30 THEN 'Standard Session'
        WHEN COALESCE(fub.SESSION_DURATION_MINUTES, 0) >= 15 THEN 'Short Session'
        WHEN COALESCE(fub.SESSION_DURATION_MINUTES, 0) >= 5 THEN 'Brief Session'
        ELSE 'Quick Access'
    END AS USAGE_CONTEXT,
    'Desktop' AS DEVICE_TYPE,
    'Latest' AS PLATFORM_VERSION,
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
