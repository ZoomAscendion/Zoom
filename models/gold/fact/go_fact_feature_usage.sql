{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, CREATED_AT, UPDATED_AT) VALUES (GENERATE_UUID(), 'go_fact_feature_usage_transformation', 'SI_FEATURE_USAGE', 'GO_FACT_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIME = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'COMPLETED', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), UPDATED_AT = CURRENT_TIMESTAMP() WHERE PROCESS_NAME = 'go_fact_feature_usage_transformation' AND PROCESS_STATUS = 'STARTED'"
) }}

-- Feature Usage Fact Table
WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.SOURCE_SYSTEM,
        m.DURATION_MINUTES,
        m.START_TIME,
        m.END_TIME
    FROM {{ source('silver', 'si_feature_usage') }} fu
    LEFT JOIN {{ source('silver', 'si_meetings') }} m 
        ON fu.MEETING_ID = m.MEETING_ID
    WHERE fu.VALIDATION_STATUS = 'PASSED'
        AND fu.DATA_QUALITY_SCORE >= 80
        AND m.VALIDATION_STATUS = 'PASSED'
),

total_features AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT FEATURE_NAME) as feature_count
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'PASSED'
    GROUP BY MEETING_ID
),

error_metrics AS (
    SELECT 
        MEETING_ID,
        FEATURE_NAME,
        COUNT(*) as error_count,
        COUNT(*) * 1.0 / NULLIF(SUM(USAGE_COUNT), 0) as error_rate
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'FAILED'
    GROUP BY MEETING_ID, FEATURE_NAME
),

feature_usage_enriched AS (
    SELECT 
        fu.USAGE_DATE,
        CURRENT_TIMESTAMP() as USAGE_TIMESTAMP,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        -- Calculate usage duration from meeting duration proportionally
        CASE 
            WHEN fu.DURATION_MINUTES > 0 AND tf.feature_count > 0 THEN 
                (fu.USAGE_COUNT * 1.0 / tf.feature_count) * fu.DURATION_MINUTES
            ELSE 0
        END as USAGE_DURATION_MINUTES,
        COALESCE(fu.DURATION_MINUTES, 0) as SESSION_DURATION_MINUTES,
        -- Classify usage intensity based on usage count
        CASE 
            WHEN fu.USAGE_COUNT >= 10 THEN 'High'
            WHEN fu.USAGE_COUNT >= 5 THEN 'Medium'
            ELSE 'Low'
        END as USAGE_INTENSITY,
        -- Calculate user experience score based on usage patterns
        CASE 
            WHEN fu.USAGE_COUNT > 0 AND fu.DURATION_MINUTES > 0 THEN 
                LEAST(10.0, (fu.USAGE_COUNT * 2.0) + (fu.DURATION_MINUTES / 10.0))
            ELSE 0
        END as USER_EXPERIENCE_SCORE,
        -- Feature performance score based on usage success
        CASE 
            WHEN fu.USAGE_COUNT > 0 THEN 
                GREATEST(1.0, 10.0 - (COALESCE(em.error_rate, 0) * 10))
            ELSE 5.0
        END as FEATURE_PERFORMANCE_SCORE,
        COALESCE(tf.feature_count, 1) as CONCURRENT_FEATURES_COUNT,
        COALESCE(em.error_count, 0) as ERROR_COUNT,
        -- Calculate success rate
        CASE 
            WHEN fu.USAGE_COUNT > 0 THEN 
                ((fu.USAGE_COUNT - COALESCE(em.error_count, 0)) * 100.0 / fu.USAGE_COUNT)
            ELSE 100.0
        END as SUCCESS_RATE_PERCENTAGE,
        -- Estimate bandwidth based on feature type and usage
        CASE 
            WHEN fu.FEATURE_NAME ILIKE '%video%' THEN fu.USAGE_COUNT * 50.0
            WHEN fu.FEATURE_NAME ILIKE '%screen%' THEN fu.USAGE_COUNT * 30.0
            WHEN fu.FEATURE_NAME ILIKE '%audio%' THEN fu.USAGE_COUNT * 5.0
            ELSE fu.USAGE_COUNT * 2.0
        END as BANDWIDTH_CONSUMED_MB,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        fu.SOURCE_SYSTEM
    FROM feature_usage_base fu
    LEFT JOIN total_features tf ON fu.MEETING_ID = tf.MEETING_ID
    LEFT JOIN error_metrics em ON fu.MEETING_ID = em.MEETING_ID 
        AND fu.FEATURE_NAME = em.FEATURE_NAME
)

SELECT * FROM feature_usage_enriched
