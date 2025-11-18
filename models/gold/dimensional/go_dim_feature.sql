{{ config(
    materialized='table',
    tags=['dimension', 'gold']
) }}

-- Feature Dimension Transformation
-- Creates feature dimension from distinct features in usage data

WITH source_features AS (
    SELECT DISTINCT
        FEATURE_NAME,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(FEATURE_NAME)) 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM DB_POC_ZOOM_1.GOLD.SI_FEATURE_USAGE
    WHERE VALIDATION_STATUS = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
),

transformed_features AS (
    SELECT 
        MD5(UPPER(TRIM(FEATURE_NAME))) as FEATURE_KEY,
        INITCAP(TRIM(FEATURE_NAME)) as FEATURE_NAME,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Engagement'
            ELSE 'General'
        END as FEATURE_CATEGORY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN 'Advanced'
            ELSE 'Standard'
        END as FEATURE_TYPE,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'High'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Medium'
            ELSE 'Low'
        END as FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN TRUE
            ELSE FALSE
        END as IS_PREMIUM_FEATURE,
        CURRENT_DATE() as FEATURE_RELEASE_DATE,
        'Active' as FEATURE_STATUS,
        'Medium' as USAGE_FREQUENCY_CATEGORY,
        'Feature usage tracking for ' || FEATURE_NAME as FEATURE_DESCRIPTION,
        'All Users' as TARGET_USER_SEGMENT,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_features
    WHERE rn = 1
)

SELECT * FROM transformed_features
