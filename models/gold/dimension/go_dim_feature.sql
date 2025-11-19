{{ config(
    materialized='table',
    unique_key='FEATURE_ID'
) }}

-- Feature dimension with categorization and characteristics

WITH source_features AS (
    SELECT DISTINCT
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM {{ source('gold_existing', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
      AND TRIM(FEATURE_NAME) != ''
),

feature_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY FEATURE_NAME) AS FEATURE_ID,
        INITCAP(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Engagement'
            WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%ANNOTATION%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' THEN 'Security'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN 'Advanced'
            WHEN UPPER(FEATURE_NAME) LIKE '%PREMIUM%' THEN 'Premium'
            ELSE 'Standard'
        END AS FEATURE_TYPE,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'High'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Medium'
            ELSE 'Low'
        END AS FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' 
              OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' 
              OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%'
              OR UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        '2020-01-01'::DATE AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'High'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Medium'
            ELSE 'Low'
        END AS USAGE_FREQUENCY_CATEGORY,
        'Feature usage tracking for ' || FEATURE_NAME AS FEATURE_DESCRIPTION,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'All Users'
            WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' OR UPPER(FEATURE_NAME) LIKE '%PREMIUM%' THEN 'Premium Users'
            ELSE 'Standard Users'
        END AS TARGET_USER_SEGMENT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_features
)

SELECT * FROM feature_dimension
