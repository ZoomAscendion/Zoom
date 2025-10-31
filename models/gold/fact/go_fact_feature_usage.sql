{{ config(
    materialized='table',
    cluster_by=['DATE_KEY', 'FEATURE_KEY']
) }}

-- Feature Usage Fact Table
WITH feature_usage_base AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DURATION,
        fu.FEATURE_CATEGORY,
        fu.USAGE_DATE,
        fu.DATA_QUALITY_SCORE,
        fu.SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.DATA_QUALITY_SCORE >= 0.8
      AND fu.USAGE_COUNT > 0
),

meeting_info AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TYPE,
        PARTICIPANT_COUNT
    FROM {{ source('silver', 'si_meetings') }}
    WHERE DATA_QUALITY_SCORE >= 0.8
),

user_info AS (
    SELECT 
        USER_ID,
        PLAN_TYPE
    FROM {{ source('silver', 'si_users') }}
    WHERE DATA_QUALITY_SCORE >= 0.8
),

fact_feature_usage AS (
    SELECT 
        CONCAT('FACT_FEAT_', fu.USAGE_ID, '_', TO_CHAR(fu.USAGE_DATE, 'YYYYMMDD')) AS FACT_FEATURE_USAGE_ID,
        fu.USAGE_DATE AS DATE_KEY,
        COALESCE(m.HOST_ID, 'UNKNOWN') AS USER_KEY,
        UPPER(REPLACE(fu.FEATURE_NAME, ' ', '_')) AS FEATURE_KEY,
        fu.USAGE_DATE,
        fu.FEATURE_NAME,
        fu.FEATURE_CATEGORY,
        fu.USAGE_COUNT,
        COALESCE(fu.USAGE_DURATION, 0) AS USAGE_DURATION_MINUTES,
        COALESCE(m.MEETING_TYPE, 'Unknown') AS MEETING_TYPE,
        COALESCE(u.PLAN_TYPE, 'Unknown') AS USER_PLAN_TYPE,
        COALESCE(m.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SILVER_LAYER' AS SOURCE_SYSTEM
    FROM feature_usage_base fu
    LEFT JOIN meeting_info m ON fu.MEETING_ID = m.MEETING_ID
    LEFT JOIN user_info u ON m.HOST_ID = u.USER_ID
)

SELECT * FROM fact_feature_usage
