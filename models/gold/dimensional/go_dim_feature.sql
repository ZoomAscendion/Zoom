{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_DIM_FEATURE_TRANSFORMATION', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', CURRENT_TIMESTAMP(), 'STARTED', 'Feature dimension transformation started', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_DIM_FEATURE_TRANSFORMATION', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', CURRENT_TIMESTAMP(), 'COMPLETED', 'Feature dimension transformation completed successfully', CURRENT_DATE(), CURRENT_DATE())"
) }}

-- Feature Dimension Table
-- Creates comprehensive feature catalog from Silver layer usage data

WITH distinct_features AS (
    SELECT DISTINCT 
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE FEATURE_NAME IS NOT NULL
        AND TRIM(FEATURE_NAME) != ''
        AND VALIDATION_STATUS = 'PASSED'
),

feature_attributes AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY FEATURE_NAME) AS FEATURE_ID,
        FEATURE_NAME,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Meeting Management'
            WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' THEN 'Media'
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' THEN 'Media'
            ELSE 'Other'
        END AS FEATURE_CATEGORY,
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('SCREEN_SHARE', 'CHAT', 'AUDIO', 'VIDEO') THEN 'Core'
            ELSE 'Advanced'
        END AS FEATURE_TYPE,
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('CHAT', 'AUDIO', 'VIDEO') THEN 'Low'
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Medium'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'High'
            ELSE 'Medium'
        END AS FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(FEATURE_NAME) NOT IN ('CHAT', 'AUDIO', 'VIDEO', 'SCREEN_SHARE') THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        '2020-01-01'::DATE AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        'Medium' AS USAGE_FREQUENCY_CATEGORY,
        'Platform feature for enhanced meeting experience' AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_TYPE,
        'Desktop, Mobile, Web' AS PLATFORM_AVAILABILITY,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM distinct_features
)

SELECT * FROM feature_attributes
ORDER BY FEATURE_ID
