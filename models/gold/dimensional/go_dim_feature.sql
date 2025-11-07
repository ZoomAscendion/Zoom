{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('GO_DIM_FEATURE_LOAD', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, PROCESS_STATUS, RECORDS_PROCESSED, RECORDS_SUCCESS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) VALUES ('GO_DIM_FEATURE_LOAD', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')"
) }}

-- Gold Layer Feature Dimension
-- Dimension table containing platform features and their characteristics for usage analysis

WITH feature_base AS (
    SELECT DISTINCT 
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE FEATURE_NAME IS NOT NULL
        AND VALIDATION_STATUS = 'PASSED'
        AND DATA_QUALITY_SCORE >= 80
),

feature_enriched AS (
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
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' THEN 'Medium'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'High'
            ELSE 'Medium'
        END AS FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(FEATURE_NAME) NOT IN ('CHAT', 'AUDIO', 'VIDEO', 'SCREEN_SHARE') THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        '2020-01-01'::DATE AS FEATURE_RELEASE_DATE, -- Default value
        'Active' AS FEATURE_STATUS,
        'Medium' AS USAGE_FREQUENCY_CATEGORY, -- Default value
        'Platform feature for enhanced meeting experience' AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_TYPE, -- Default value
        'Desktop, Mobile, Web' AS PLATFORM_AVAILABILITY, -- Default value
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM feature_base
)

SELECT * FROM feature_enriched
