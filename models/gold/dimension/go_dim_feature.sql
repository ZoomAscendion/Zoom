{{ config(
    materialized='table',
    cluster_by=['FEATURE_CATEGORY', 'LOAD_DATE'],
    tags=['dimension', 'feature']
) }}

-- Feature dimension containing platform features and their characteristics
-- Derived from Silver layer feature usage data with intelligent categorization

WITH source_features AS (
    SELECT DISTINCT 
        feature_name
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE feature_name IS NOT NULL 
        AND TRIM(feature_name) != ''
        AND validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
),

feature_categorization AS (
    SELECT 
        feature_name,
        
        -- Intelligent feature categorization based on name patterns
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%PLAYBACK%' THEN 'Recording'
            WHEN UPPER(feature_name) LIKE '%CHAT%' OR UPPER(feature_name) LIKE '%MESSAGE%' THEN 'Communication'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%ROOM%' THEN 'Meeting Management'
            WHEN UPPER(feature_name) LIKE '%VIDEO%' OR UPPER(feature_name) LIKE '%CAMERA%' THEN 'Video'
            WHEN UPPER(feature_name) LIKE '%AUDIO%' OR UPPER(feature_name) LIKE '%MIC%' OR UPPER(feature_name) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(feature_name) LIKE '%POLL%' OR UPPER(feature_name) LIKE '%SURVEY%' THEN 'Engagement'
            WHEN UPPER(feature_name) LIKE '%SECURITY%' OR UPPER(feature_name) LIKE '%LOCK%' THEN 'Security'
            WHEN UPPER(feature_name) LIKE '%ANNOTATION%' OR UPPER(feature_name) LIKE '%DRAW%' THEN 'Annotation'
            ELSE 'Other'
        END AS feature_category,
        
        -- Feature type classification
        CASE 
            WHEN UPPER(feature_name) IN ('AUDIO', 'VIDEO', 'CHAT', 'SCREEN_SHARE') THEN 'Core'
            WHEN UPPER(feature_name) LIKE '%BASIC%' THEN 'Basic'
            ELSE 'Advanced'
        END AS feature_type,
        
        -- Feature complexity assessment
        CASE 
            WHEN UPPER(feature_name) IN ('AUDIO', 'VIDEO', 'CHAT') THEN 'Low'
            WHEN UPPER(feature_name) LIKE '%SCREEN%' OR UPPER(feature_name) LIKE '%SHARE%' THEN 'Medium'
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'High'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%ANNOTATION%' THEN 'High'
            ELSE 'Medium'
        END AS feature_complexity,
        
        -- Premium feature indicator
        CASE 
            WHEN UPPER(feature_name) LIKE '%RECORD%' 
                OR UPPER(feature_name) LIKE '%BREAKOUT%' 
                OR UPPER(feature_name) LIKE '%WHITEBOARD%'
                OR UPPER(feature_name) LIKE '%POLL%'
                OR UPPER(feature_name) LIKE '%WEBINAR%' THEN TRUE
            ELSE FALSE
        END AS is_premium_feature,
        
        -- Estimated feature release date (for demonstration)
        CASE 
            WHEN UPPER(feature_name) IN ('AUDIO', 'VIDEO', 'CHAT') THEN '2020-01-01'::DATE
            WHEN UPPER(feature_name) LIKE '%SCREEN%' THEN '2020-03-01'::DATE
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN '2020-06-01'::DATE
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN '2021-01-01'::DATE
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' THEN '2021-06-01'::DATE
            ELSE '2020-01-01'::DATE
        END AS feature_release_date,
        
        -- Feature status
        'Active' AS feature_status,
        
        -- Usage frequency category (estimated)
        CASE 
            WHEN UPPER(feature_name) IN ('AUDIO', 'VIDEO') THEN 'Very High'
            WHEN UPPER(feature_name) IN ('CHAT', 'SCREEN_SHARE') THEN 'High'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Medium'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Low'
            ELSE 'Medium'
        END AS usage_frequency_category,
        
        -- Feature description
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Share screen content with meeting participants'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Record meeting sessions for later playback'
            WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Send text messages during meetings'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Create separate discussion rooms within meetings'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Collaborative digital whiteboard for visual collaboration'
            WHEN UPPER(feature_name) LIKE '%POLL%' THEN 'Create interactive polls and surveys'
            WHEN UPPER(feature_name) LIKE '%AUDIO%' THEN 'Audio communication functionality'
            WHEN UPPER(feature_name) LIKE '%VIDEO%' THEN 'Video communication functionality'
            ELSE 'Platform feature for enhanced meeting experience'
        END AS feature_description,
        
        -- Target user type
        CASE 
            WHEN UPPER(feature_name) IN ('AUDIO', 'VIDEO', 'CHAT') THEN 'All Users'
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Business Users'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%POLL%' THEN 'Enterprise Users'
            ELSE 'General Users'
        END AS target_user_type,
        
        -- Platform availability
        CASE 
            WHEN UPPER(feature_name) IN ('AUDIO', 'VIDEO', 'CHAT', 'SCREEN_SHARE') THEN 'All Platforms'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Desktop, Mobile'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Desktop, Web'
            ELSE 'Desktop, Web, Mobile'
        END AS platform_availability
        
    FROM source_features
),

final_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY feature_name) AS feature_id,
        feature_name,
        feature_category,
        feature_type,
        feature_complexity,
        is_premium_feature,
        feature_release_date,
        feature_status,
        usage_frequency_category,
        feature_description,
        target_user_type,
        platform_availability,
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'SI_FEATURE_USAGE' AS source_system
        
    FROM feature_categorization
)

SELECT * FROM final_dimension
ORDER BY feature_category, feature_name
