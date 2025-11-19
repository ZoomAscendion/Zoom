{{
  config(
    materialized='table',
    cluster_by=['FEATURE_ID', 'FEATURE_CATEGORY'],
    tags=['dimension', 'gold']
  )
}}

-- Feature Dimension Table
-- Transforms distinct features from Silver layer into comprehensive feature dimension

WITH source_features AS (
    SELECT DISTINCT
        COALESCE(FEATURE_NAME, 'Unknown Feature') AS FEATURE_NAME,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE COALESCE(VALIDATION_STATUS, 'PASSED') = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
),

feature_attributes AS (
    SELECT 
        -- Primary Key
        ROW_NUMBER() OVER (ORDER BY FEATURE_NAME) AS FEATURE_ID,
        
        -- Feature Information
        INITCAP(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        
        -- Feature Categorization
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Engagement'
            ELSE 'General'
        END AS FEATURE_CATEGORY,
        
        -- Feature Type
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN 'Advanced'
            ELSE 'Standard'
        END AS FEATURE_TYPE,
        
        -- Feature Complexity
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'High'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Medium'
            ELSE 'Low'
        END AS FEATURE_COMPLEXITY,
        
        -- Premium Feature Flag
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        
        -- Feature Attributes
        '2020-01-01'::DATE AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        'Medium' AS USAGE_FREQUENCY_CATEGORY,
        'Feature usage tracking for ' || FEATURE_NAME AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_SEGMENT,
        
        -- Metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_features
)

SELECT * FROM feature_attributes
