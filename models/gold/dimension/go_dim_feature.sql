{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_dim_feature', 'SI_FEATURE_USAGE', 'go_dim_feature', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_dim_feature' AND process_status = 'STARTED'"
) }}

-- Feature dimension with categorization
WITH source_features AS (
    SELECT DISTINCT
        COALESCE(TRIM(feature_name), 'Unknown Feature') AS feature_name,
        source_system
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE feature_name IS NOT NULL
      AND TRIM(feature_name) != ''
),

transformed_features AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY feature_name) AS feature_id,
        INITCAP(feature_name) AS feature_name,
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
            WHEN UPPER(feature_name) LIKE '%POLL%' THEN 'Engagement'
            ELSE 'General'
        END AS feature_category,
        CASE 
            WHEN UPPER(feature_name) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(feature_name) LIKE '%ADVANCED%' THEN 'Advanced'
            ELSE 'Standard'
        END AS feature_type,
        CASE 
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%POLL%' THEN 'High'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Medium'
            ELSE 'Low'
        END AS feature_complexity,
        CASE 
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%BREAKOUT%' THEN TRUE
            ELSE FALSE
        END AS is_premium_feature,
        '2020-01-01'::DATE AS feature_release_date,
        'Active' AS feature_status,
        'Medium' AS usage_frequency_category,
        'Feature usage tracking for ' || feature_name AS feature_description,
        'All Users' AS target_user_segment,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM source_features
)

SELECT * FROM transformed_features
