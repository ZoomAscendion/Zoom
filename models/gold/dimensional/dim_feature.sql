{{
  config(
    materialized='table',
    cluster_by=['FEATURE_KEY'],
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, LOAD_DATE, SOURCE_SYSTEM) SELECT '{{ invocation_id }}', 'DIM_FEATURE_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_audit_log'",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIMESTAMP, CURRENT_TIMESTAMP()) WHERE AUDIT_LOG_ID = '{{ invocation_id }}' AND '{{ this.name }}' != 'go_audit_log'"
  )
}}

-- Feature Dimension Transformation
WITH feature_data AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['FEATURE_NAME']) }} AS FEATURE_KEY,
        ROW_NUMBER() OVER (ORDER BY FEATURE_NAME) AS FEATURE_ID,
        INITCAP(TRIM(COALESCE(FEATURE_NAME, 'Unknown'))) AS FEATURE_NAME,
        CASE 
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%POLL%' THEN 'Engagement'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        CASE 
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%ADVANCED%' THEN 'Advanced'
            ELSE 'Standard'
        END AS FEATURE_TYPE,
        CASE 
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%BREAKOUT%' OR UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%POLL%' THEN 'High'
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%RECORD%' THEN 'Medium'
            ELSE 'Low'
        END AS FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%RECORD%' OR UPPER(COALESCE(FEATURE_NAME, '')) LIKE '%BREAKOUT%' THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        CURRENT_DATE() AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        'Medium' AS USAGE_FREQUENCY_CATEGORY,
        'Feature usage tracking for ' || COALESCE(FEATURE_NAME, 'Unknown') AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_SEGMENT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'SILVER_LAYER') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE COALESCE(VALIDATION_STATUS, '') = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
      AND TRIM(FEATURE_NAME) != ''
)

SELECT * FROM feature_data
