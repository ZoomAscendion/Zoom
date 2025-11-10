/*
  go_dim_feature.sql
  Zoom Platform Analytics System - Feature Dimension
  
  Author: Data Engineering Team
  Description: Feature dimension containing platform features and their characteristics
  
  This model creates a comprehensive feature dimension with categorization,
  complexity assessment, and premium feature identification.
*/

{{ config(
    materialized='table',
    tags=['dimension', 'feature'],
    cluster_by=['feature_category', 'feature_type']
) }}

-- Extract unique features from usage data
WITH source_features AS (
    SELECT DISTINCT
        UPPER(TRIM(feature_name)) AS feature_name,
        MIN(usage_date) AS first_usage_date,
        MAX(usage_date) AS last_usage_date,
        COUNT(DISTINCT meeting_id) AS meetings_used_count,
        SUM(usage_count) AS total_usage_count,
        source_system
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE feature_name IS NOT NULL
        AND validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
    GROUP BY UPPER(TRIM(feature_name)), source_system
),

-- Feature categorization and attributes
feature_attributes AS (
    SELECT 
        feature_name,
        
        -- Feature categorization based on functionality
        CASE 
            WHEN feature_name LIKE '%SCREEN%SHARE%' OR feature_name LIKE '%SHARE%SCREEN%' THEN 'Collaboration'
            WHEN feature_name LIKE '%RECORD%' OR feature_name LIKE '%RECORDING%' THEN 'Recording'
            WHEN feature_name LIKE '%CHAT%' OR feature_name LIKE '%MESSAGE%' THEN 'Communication'
            WHEN feature_name LIKE '%BREAKOUT%' OR feature_name LIKE '%ROOM%' THEN 'Meeting Management'
            WHEN feature_name LIKE '%WHITEBOARD%' OR feature_name LIKE '%ANNOTATION%' THEN 'Collaboration'
            WHEN feature_name LIKE '%POLL%' OR feature_name LIKE '%SURVEY%' THEN 'Engagement'
            WHEN feature_name LIKE '%AUDIO%' OR feature_name LIKE '%MICROPHONE%' OR feature_name LIKE '%MIC%' THEN 'Audio'
            WHEN feature_name LIKE '%VIDEO%' OR feature_name LIKE '%CAMERA%' OR feature_name LIKE '%CAM%' THEN 'Video'
            WHEN feature_name LIKE '%FILE%' OR feature_name LIKE '%DOCUMENT%' OR feature_name LIKE '%SHARE%' THEN 'File Sharing'
            WHEN feature_name LIKE '%SECURITY%' OR feature_name LIKE '%LOCK%' OR feature_name LIKE '%PASSWORD%' THEN 'Security'
            WHEN feature_name LIKE '%MOBILE%' OR feature_name LIKE '%PHONE%' THEN 'Mobile'
            ELSE 'Other'
        END AS feature_category,
        
        -- Feature type classification
        CASE 
            WHEN feature_name IN ('AUDIO', 'VIDEO', 'CHAT', 'SCREEN_SHARE') THEN 'Core'
            WHEN feature_name LIKE '%BASIC%' OR feature_name LIKE '%STANDARD%' THEN 'Standard'
            WHEN feature_name LIKE '%ADVANCED%' OR feature_name LIKE '%PRO%' THEN 'Advanced'
            WHEN feature_name LIKE '%ENTERPRISE%' OR feature_name LIKE '%ADMIN%' THEN 'Enterprise'
            ELSE 'Standard'
        END AS feature_type,
        
        -- Feature complexity assessment
        CASE 
            WHEN feature_name IN ('AUDIO', 'VIDEO', 'CHAT') THEN 'Low'
            WHEN feature_name IN ('SCREEN_SHARE', 'FILE_SHARE', 'RECORDING') THEN 'Medium'
            WHEN feature_name LIKE '%BREAKOUT%' OR feature_name LIKE '%WHITEBOARD%' OR feature_name LIKE '%API%' THEN 'High'
            WHEN feature_name LIKE '%INTEGRATION%' OR feature_name LIKE '%SSO%' OR feature_name LIKE '%ADMIN%' THEN 'Very High'
            ELSE 'Medium'
        END AS feature_complexity,
        
        -- Premium feature identification
        CASE 
            WHEN feature_name LIKE '%ENTERPRISE%' OR feature_name LIKE '%ADMIN%' OR feature_name LIKE '%API%' THEN TRUE
            WHEN feature_name LIKE '%BREAKOUT%' OR feature_name LIKE '%WHITEBOARD%' OR feature_name LIKE '%RECORDING%' THEN TRUE
            WHEN feature_name LIKE '%INTEGRATION%' OR feature_name LIKE '%SSO%' THEN TRUE
            WHEN feature_type IN ('Advanced', 'Enterprise') THEN TRUE
            ELSE FALSE
        END AS is_premium_feature,
        
        -- Feature release date (estimated based on first usage)
        first_usage_date AS feature_release_date,
        
        -- Feature status
        CASE 
            WHEN last_usage_date >= CURRENT_DATE - 30 THEN 'Active'
            WHEN last_usage_date >= CURRENT_DATE - 90 THEN 'Low Usage'
            ELSE 'Deprecated'
        END AS feature_status,
        
        -- Usage frequency category
        CASE 
            WHEN total_usage_count >= 10000 THEN 'Very High'
            WHEN total_usage_count >= 1000 THEN 'High'
            WHEN total_usage_count >= 100 THEN 'Medium'
            WHEN total_usage_count >= 10 THEN 'Low'
            ELSE 'Very Low'
        END AS usage_frequency_category,
        
        -- Feature description (generated based on name and category)
        CASE 
            WHEN feature_category = 'Audio' THEN 'Audio communication feature for voice interaction'
            WHEN feature_category = 'Video' THEN 'Video communication feature for visual interaction'
            WHEN feature_category = 'Collaboration' THEN 'Collaboration tool for enhanced teamwork'
            WHEN feature_category = 'Recording' THEN 'Recording capability for meeting documentation'
            WHEN feature_category = 'Communication' THEN 'Communication tool for participant interaction'
            WHEN feature_category = 'Meeting Management' THEN 'Meeting management feature for organization'
            WHEN feature_category = 'Engagement' THEN 'Engagement tool for participant involvement'
            WHEN feature_category = 'File Sharing' THEN 'File sharing capability for document collaboration'
            WHEN feature_category = 'Security' THEN 'Security feature for meeting protection'
            WHEN feature_category = 'Mobile' THEN 'Mobile-specific feature for device compatibility'
            ELSE 'Platform feature for enhanced functionality'
        END AS feature_description,
        
        -- Target user type
        CASE 
            WHEN is_premium_feature THEN 'Business Users'
            WHEN feature_complexity IN ('High', 'Very High') THEN 'Advanced Users'
            WHEN feature_type = 'Core' THEN 'All Users'
            ELSE 'Standard Users'
        END AS target_user_type,
        
        -- Platform availability
        CASE 
            WHEN feature_name LIKE '%MOBILE%' THEN 'Mobile Only'
            WHEN feature_name LIKE '%DESKTOP%' THEN 'Desktop Only'
            WHEN feature_name LIKE '%WEB%' THEN 'Web Only'
            ELSE 'All Platforms'
        END AS platform_availability,
        
        first_usage_date,
        last_usage_date,
        meetings_used_count,
        total_usage_count,
        source_system
        
    FROM source_features
),

-- Final dimension with surrogate key
final_dimension AS (
    SELECT 
        -- Generate surrogate key
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
        
        -- Metadata columns
        CURRENT_DATE AS load_date,
        CURRENT_DATE AS update_date,
        source_system
        
    FROM feature_attributes
)

SELECT 
    feature_id,
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
    load_date,
    update_date,
    source_system
FROM final_dimension
ORDER BY feature_id