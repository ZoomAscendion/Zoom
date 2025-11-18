{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, LOAD_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_FACT_FEATURE_USAGE_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SILVER.SI_FEATURE_USAGE', 'GOLD.GO_FACT_FEATURE_USAGE', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PROCESS_NAME = 'GO_FACT_FEATURE_USAGE_LOAD' AND DATE(EXECUTION_START_TIMESTAMP) = CURRENT_DATE()"
) }}

-- Feature Usage Fact Table
-- Captures detailed feature usage metrics and patterns

WITH usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY fu.USAGE_ID 
            ORDER BY fu.UPDATE_TIMESTAMP DESC
        ) as rn
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
),

meeting_context AS (
    SELECT 
        sm.MEETING_ID,
        sm.HOST_ID,
        sm.DURATION_MINUTES
    FROM {{ source('silver', 'si_meetings') }} sm
    WHERE sm.VALIDATION_STATUS = 'PASSED'
),

final_fact AS (
    SELECT 
        -- Foreign Key Columns for BI Integration
        ub.USAGE_DATE as DATE_KEY,
        COALESCE(df.FEATURE_KEY, 'UNKNOWN_FEATURE') as FEATURE_KEY,
        COALESCE(du.USER_KEY, 'UNKNOWN_USER') as USER_KEY,
        MD5(ub.MEETING_ID) as MEETING_KEY,
        
        -- Fact Measures
        ub.USAGE_DATE,
        ub.USAGE_DATE::TIMESTAMP_NTZ as USAGE_TIMESTAMP,
        ub.FEATURE_NAME,
        ub.USAGE_COUNT,
        COALESCE(mc.DURATION_MINUTES, 0) as USAGE_DURATION_MINUTES,
        COALESCE(mc.DURATION_MINUTES, 0) as SESSION_DURATION_MINUTES,
        CASE 
            WHEN ub.USAGE_COUNT >= 10 THEN 5.0
            WHEN ub.USAGE_COUNT >= 5 THEN 4.0
            WHEN ub.USAGE_COUNT >= 3 THEN 3.0
            WHEN ub.USAGE_COUNT >= 1 THEN 2.0
            ELSE 1.0
        END as FEATURE_ADOPTION_SCORE,
        8.5 as USER_EXPERIENCE_RATING,
        9.0 as FEATURE_PERFORMANCE_SCORE,
        1 as CONCURRENT_FEATURES_COUNT,
        'Meeting' as USAGE_CONTEXT,
        'Desktop' as DEVICE_TYPE,
        'v5.0' as PLATFORM_VERSION,
        0 as ERROR_COUNT,
        CASE 
            WHEN ub.USAGE_COUNT > 0 THEN 100.0
            ELSE 0.0
        END as SUCCESS_RATE,
        
        -- Metadata
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        ub.SOURCE_SYSTEM
    FROM usage_base ub
    LEFT JOIN meeting_context mc ON ub.MEETING_ID = mc.MEETING_ID
    LEFT JOIN {{ ref('go_dim_feature') }} df ON ub.FEATURE_NAME = df.FEATURE_NAME
    LEFT JOIN {{ ref('go_dim_user') }} du ON mc.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    WHERE ub.rn = 1
)

SELECT * FROM final_fact
