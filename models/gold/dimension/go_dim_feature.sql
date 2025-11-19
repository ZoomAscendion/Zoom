{{ config(
    materialized='table'
) }}

-- Feature dimension with categorization and characteristics
-- Derived from distinct features in Silver layer feature usage

WITH source_features AS (
    SELECT DISTINCT
        feature_name,
        source_system
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = 'PASSED'
      AND feature_name IS NOT NULL
      AND TRIM(feature_name) != ''
),

transformed_features AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY feature_name) AS feature_id,
        INITCAP(TRIM(feature_name)) AS feature_name,
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%SHARE%SCREEN%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(feature_name) LIKE '%CHAT%' OR UPPER(feature_name) LIKE '%MESSAGE%' THEN 'Communication'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%ROOM%' THEN 'Advanced Meeting'
            WHEN UPPER(feature_name) LIKE '%POLL%' OR UPPER(feature_name) LIKE '%SURVEY%' THEN 'Engagement'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%ANNOTATION%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%SECURITY%' OR UPPER(feature_name) LIKE '%LOCK%' THEN 'Security'
            ELSE 'General'
        END AS feature_category,
        CASE 
            WHEN UPPER(feature_name) LIKE '%BASIC%' THEN 'Core'
            WHEN UPPER(feature_name) LIKE '%ADVANCED%' OR UPPER(feature_name) LIKE '%PRO%' THEN 'Advanced'
            ELSE 'Standard'
        END AS feature_type,
        CASE 
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%POLL%' OR 
                 UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'High'
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%SHARE%' THEN 'Medium'
            ELSE 'Low'
        END AS feature_complexity,
        CASE 
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%BREAKOUT%' OR
                 UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%POLL%' THEN TRUE
            ELSE FALSE
        END AS is_premium_feature,
        '2020-01-01'::DATE AS feature_release_date,
        'Active' AS feature_status,
        CASE 
            WHEN UPPER(feature_name) LIKE '%CHAT%' OR UPPER(feature_name) LIKE '%SHARE%' THEN 'High'
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%POLL%' THEN 'Medium'
            ELSE 'Low'
        END AS usage_frequency_category,
        'Feature usage tracking for ' || INITCAP(TRIM(feature_name)) AS feature_description,
        CASE 
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%POLL%' THEN 'Business Users'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Professional Users'
            ELSE 'All Users'
        END AS target_user_segment,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM source_features
)

SELECT * FROM transformed_features
