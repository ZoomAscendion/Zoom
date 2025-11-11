{{
  config(
    materialized='table',
    cluster_by=['FEATURE_KEY'],
    tags=['dimension', 'gold']
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
        COALESCE(SOURCE_SYSTEM, 'SILVER') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE COALESCE(VALIDATION_STATUS, '') = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
      AND TRIM(FEATURE_NAME) != ''
)

SELECT * FROM feature_data
