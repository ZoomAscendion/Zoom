{{
  config(
    materialized='table',
    cluster_by=['FEATURE_ID', 'FEATURE_CATEGORY'],
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_dim_feature', run_started_at]) }}', 'go_dim_feature', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_dim_feature_complete', run_started_at]) }}', 'go_dim_feature', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_FEATURE_USAGE', 'GO_DIM_FEATURE', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'"
  )
}}

-- Feature Dimension Table
-- Transforms distinct features from Silver layer into comprehensive feature dimension

WITH source_features AS (
    SELECT DISTINCT
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE VALIDATION_STATUS = 'PASSED'
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
