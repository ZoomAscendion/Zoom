{{ config(
    materialized='table'
) }}

-- Feature Dimension Table
-- Creates comprehensive feature dimension from Silver layer feature usage data

WITH source_features AS (
    SELECT DISTINCT
        COALESCE(FEATURE_NAME, 'Unknown Feature') AS FEATURE_NAME,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
),

feature_transformations AS (
    SELECT 
        MD5(UPPER(TRIM(FEATURE_NAME))) AS FEATURE_KEY,
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
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN 'Advanced'
            ELSE 'Standard'
        END AS FEATURE_TYPE,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'High'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Medium'
            ELSE 'Low'
        END AS FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' 
                 OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        CURRENT_DATE() - INTERVAL '1 YEAR' AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        'Medium' AS USAGE_FREQUENCY_CATEGORY,
        'Feature usage tracking for ' || FEATURE_NAME AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_SEGMENT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_features
),

deduped_features AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY FEATURE_NAME 
            ORDER BY LOAD_DATE DESC
        ) AS rn
    FROM feature_transformations
)

SELECT 
    FEATURE_KEY,
    FEATURE_ID,
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
FROM deduped_features
WHERE rn = 1
