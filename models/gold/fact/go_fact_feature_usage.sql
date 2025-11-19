{{
  config(
    materialized='table',
    cluster_by=['DATE_ID', 'FEATURE_ID', 'USER_DIM_ID'],
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_fact_feature_usage', run_started_at]) }}', 'go_fact_feature_usage', 'FACT_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_fact_feature_usage_complete', run_started_at]) }}', 'go_fact_feature_usage', 'FACT_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'"
  )
}}

-- Feature Usage Fact Table
-- Captures detailed feature usage metrics and patterns with dimensional relationships

WITH feature_usage_base AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

meeting_context AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        DURATION_MINUTES,
        START_TIME
    FROM {{ source('silver', 'si_meetings') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

feature_usage_facts AS (
    SELECT 
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['fub.USAGE_ID']) }} AS FEATURE_USAGE_ID,
        
        -- Foreign Keys
        dd.DATE_ID,
        COALESCE(df.FEATURE_ID, 1) AS FEATURE_ID,
        COALESCE(du.USER_DIM_ID, 1) AS USER_DIM_ID,
        fub.MEETING_ID,
        
        -- Usage Information
        fub.USAGE_DATE,
        fub.USAGE_DATE::TIMESTAMP_NTZ AS USAGE_TIMESTAMP,
        fub.FEATURE_NAME,
        fub.USAGE_COUNT,
        
        -- Usage Metrics
        COALESCE(mc.DURATION_MINUTES, 0) AS USAGE_DURATION_MINUTES,
        COALESCE(mc.DURATION_MINUTES, 0) AS SESSION_DURATION_MINUTES,
        
        -- Feature Adoption Score
        CASE 
            WHEN fub.USAGE_COUNT >= 10 THEN 5.0
            WHEN fub.USAGE_COUNT >= 5 THEN 4.0
            WHEN fub.USAGE_COUNT >= 3 THEN 3.0
            WHEN fub.USAGE_COUNT >= 1 THEN 2.0
            ELSE 1.0
        END AS FEATURE_ADOPTION_SCORE,
        
        -- User Experience Rating
        CASE 
            WHEN fub.USAGE_COUNT >= 5 THEN 5.0
            WHEN fub.USAGE_COUNT >= 3 THEN 4.0
            WHEN fub.USAGE_COUNT >= 2 THEN 3.0
            WHEN fub.USAGE_COUNT >= 1 THEN 2.0
            ELSE 1.0
        END AS USER_EXPERIENCE_RATING,
        
        -- Feature Performance Score
        CASE 
            WHEN fub.USAGE_COUNT > 0 THEN 5.0
            ELSE 1.0
        END AS FEATURE_PERFORMANCE_SCORE,
        
        -- Concurrent Features Count (placeholder)
        1 AS CONCURRENT_FEATURES_COUNT,
        
        -- Usage Context
        CASE 
            WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 60 THEN 'Extended Session'
            WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 30 THEN 'Standard Session'
            WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 15 THEN 'Short Session'
            WHEN COALESCE(mc.DURATION_MINUTES, 0) >= 5 THEN 'Brief Session'
            ELSE 'Quick Access'
        END AS USAGE_CONTEXT,
        
        -- Technical Metrics
        'Desktop' AS DEVICE_TYPE, -- Default value
        '1.0.0' AS PLATFORM_VERSION, -- Default value
        0 AS ERROR_COUNT, -- Default value
        
        -- Success Rate
        CASE 
            WHEN fub.USAGE_COUNT > 0 THEN 100.0
            ELSE 0.0
        END AS SUCCESS_RATE,
        
        -- Metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        fub.SOURCE_SYSTEM
    FROM feature_usage_base fub
    LEFT JOIN {{ ref('go_dim_date') }} dd ON fub.USAGE_DATE = dd.DATE_VALUE
    LEFT JOIN {{ ref('go_dim_feature') }} df ON fub.FEATURE_NAME = df.FEATURE_NAME
    LEFT JOIN meeting_context mc ON fub.MEETING_ID = mc.MEETING_ID
    LEFT JOIN {{ ref('go_dim_user') }} du ON mc.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
)

SELECT * FROM feature_usage_facts
