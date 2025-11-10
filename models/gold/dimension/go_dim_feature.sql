{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, CREATED_AT, UPDATED_AT) VALUES (GENERATE_UUID(), 'go_dim_feature_transformation', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIME = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'COMPLETED', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), UPDATED_AT = CURRENT_TIMESTAMP() WHERE PROCESS_NAME = 'go_dim_feature_transformation' AND PROCESS_STATUS = 'STARTED'"
) }}

-- Feature Dimension Table
WITH feature_base AS (
    SELECT DISTINCT 
        FEATURE_NAME
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE FEATURE_NAME IS NOT NULL
        AND VALIDATION_STATUS = 'PASSED'
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
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%' THEN 'Medium'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'High'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'High'
            ELSE 'Medium'
        END AS FEATURE_COMPLEXITY,
        CASE 
            WHEN UPPER(FEATURE_NAME) NOT IN ('CHAT', 'AUDIO', 'VIDEO') THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        '2020-01-01'::DATE AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        'High' AS USAGE_FREQUENCY_CATEGORY,
        'Platform feature for enhanced meeting experience' AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_TYPE,
        'Desktop, Mobile, Web' AS PLATFORM_AVAILABILITY,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SI_FEATURE_USAGE' AS SOURCE_SYSTEM
    FROM feature_base
)

SELECT * FROM feature_enriched
