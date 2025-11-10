{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS) VALUES (GENERATE_UUID(), 'GO_DIM_FEATURE', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', CURRENT_TIMESTAMP(), 'STARTED')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_END_TIME, EXECUTION_STATUS, RECORDS_PROCESSED) VALUES (GENERATE_UUID(), 'GO_DIM_FEATURE', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}))"
) }}

-- Gold Dimension: Feature Dimension
-- Description: Platform features and their characteristics

WITH source_features AS (
    SELECT DISTINCT 
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE FEATURE_NAME IS NOT NULL
),

feature_categorization AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY FEATURE_NAME) AS FEATURE_ID,
        FEATURE_NAME,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Meeting Management'
            WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' THEN 'Communication'
            ELSE 'Other'
        END AS FEATURE_CATEGORY,
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('SCREEN_SHARE', 'CHAT', 'AUDIO', 'VIDEO') THEN 'Core'
            ELSE 'Advanced'
        END AS FEATURE_TYPE,
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('AUDIO', 'VIDEO', 'CHAT') THEN 'Low'
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Medium'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'High'
            ELSE 'Medium'
        END AS FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        '2020-01-01'::DATE AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        'High' AS USAGE_FREQUENCY_CATEGORY,
        'Feature for ' || FEATURE_NAME AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_TYPE,
        'Desktop, Mobile, Web' AS PLATFORM_AVAILABILITY,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_features
)

SELECT * FROM feature_categorization
