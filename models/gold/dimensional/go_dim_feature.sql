{{ config(
    materialized='table',
    tags=['dimension', 'gold']
) }}

-- Feature dimension transformation from Silver layer
WITH feature_data AS (
    SELECT DISTINCT
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
),

feature_transformed AS (
    SELECT 
        MD5(UPPER(TRIM(FEATURE_NAME))) AS FEATURE_KEY,
        INITCAP(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Engagement'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN 'Advanced'
            ELSE 'Standard'
        END AS FEATURE_TYPE,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'High'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Medium'
            ELSE 'Low'
        END AS FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        CURRENT_DATE() AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        'Medium' AS USAGE_FREQUENCY_CATEGORY,
        'Feature usage tracking for ' || FEATURE_NAME AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_SEGMENT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM feature_data
)

SELECT 
    FEATURE_KEY,
    ROW_NUMBER() OVER (ORDER BY FEATURE_KEY) AS FEATURE_ID,
    FEATURE_NAME,
    FEATURE_CATEGORY,
    FEATURE_TYPE,
    FEATURE_COMPLEXITY,
    IS_PREMIUM_FEATURE,
    FEATURE_RELEASE_DATE,
    FEATURE_STATUS,
    USAGE_FREQUENCY_CATEGORY,
    FEATURE_DESCRIPTION,
    TARGET_USER_SEGMENT,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM feature_transformed
