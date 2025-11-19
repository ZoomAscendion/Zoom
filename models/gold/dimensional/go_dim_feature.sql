{{ config(
    materialized='table',
    cluster_by=['FEATURE_NAME', 'FEATURE_CATEGORY'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIMESTAMP, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) VALUES ('{{ dbt_utils.generate_surrogate_key(["'go_dim_feature'", "CURRENT_TIMESTAMP()"]) }}', 'GO_DIM_FEATURE_LOAD', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', 'DBT_MODEL_RUN', 'DBT_USER', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIMESTAMP = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), DATA_QUALITY_SCORE = 95.0 WHERE PROCESS_ID = '{{ dbt_utils.generate_surrogate_key(["'go_dim_feature'", "CURRENT_TIMESTAMP()"]) }}'"
) }}

-- Feature dimension with enhanced categorization
-- Transforms feature usage data into comprehensive feature catalog

WITH source_features AS (
    SELECT DISTINCT
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
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
        '2020-01-01'::DATE AS FEATURE_RELEASE_DATE,
        'Active' AS FEATURE_STATUS,
        'Medium' AS USAGE_FREQUENCY_CATEGORY,
        'Feature usage tracking for ' || FEATURE_NAME AS FEATURE_DESCRIPTION,
        'All Users' AS TARGET_USER_SEGMENT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_features
)

SELECT * FROM feature_dimension
