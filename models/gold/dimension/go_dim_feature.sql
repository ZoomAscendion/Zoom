{{ config(
    materialized='table',
    tags=['dimension'],
    cluster_by=['FEATURE_NAME', 'FEATURE_CATEGORY']
) }}

-- Feature dimension table with comprehensive feature characteristics
-- Transforms Silver feature usage data into business-ready dimensional format

WITH feature_base AS (
    SELECT DISTINCT
        fu.feature_name
    FROM {{ source('silver', 'si_feature_usage') }} fu
    WHERE fu.validation_status = 'PASSED'
      AND fu.data_quality_score >= 80
      AND fu.feature_name IS NOT NULL
      AND TRIM(fu.feature_name) != ''
),

feature_enriched AS (
    SELECT 
        fb.feature_name,
        
        -- Categorize features based on name patterns
        CASE 
            WHEN UPPER(fb.feature_name) LIKE '%VIDEO%' OR UPPER(fb.feature_name) LIKE '%CAMERA%' THEN 'Video'
            WHEN UPPER(fb.feature_name) LIKE '%AUDIO%' OR UPPER(fb.feature_name) LIKE '%MIC%' OR UPPER(fb.feature_name) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(fb.feature_name) LIKE '%SCREEN%' OR UPPER(fb.feature_name) LIKE '%SHARE%' THEN 'Screen Sharing'
            WHEN UPPER(fb.feature_name) LIKE '%CHAT%' OR UPPER(fb.feature_name) LIKE '%MESSAGE%' THEN 'Communication'
            WHEN UPPER(fb.feature_name) LIKE '%RECORD%' OR UPPER(fb.feature_name) LIKE '%SAVE%' THEN 'Recording'
            WHEN UPPER(fb.feature_name) LIKE '%BREAKOUT%' OR UPPER(fb.feature_name) LIKE '%ROOM%' THEN 'Collaboration'
            WHEN UPPER(fb.feature_name) LIKE '%FILE%' OR UPPER(fb.feature_name) LIKE '%DOCUMENT%' THEN 'File Management'
            WHEN UPPER(fb.feature_name) LIKE '%POLL%' OR UPPER(fb.feature_name) LIKE '%SURVEY%' THEN 'Engagement'
            ELSE 'Other'
        END AS feature_category,
        
        -- Feature type classification
        CASE 
            WHEN UPPER(fb.feature_name) LIKE '%BASIC%' OR UPPER(fb.feature_name) LIKE '%STANDARD%' THEN 'Core'
            WHEN UPPER(fb.feature_name) LIKE '%ADVANCED%' OR UPPER(fb.feature_name) LIKE '%PRO%' THEN 'Advanced'
            WHEN UPPER(fb.feature_name) LIKE '%PREMIUM%' OR UPPER(fb.feature_name) LIKE '%ENTERPRISE%' THEN 'Premium'
            ELSE 'Standard'
        END AS feature_type,
        
        -- Feature complexity assessment
        CASE 
            WHEN UPPER(fb.feature_name) LIKE '%BREAKOUT%' OR UPPER(fb.feature_name) LIKE '%ADVANCED%' THEN 'High'
            WHEN UPPER(fb.feature_name) LIKE '%SCREEN%' OR UPPER(fb.feature_name) LIKE '%RECORD%' THEN 'Medium'
            ELSE 'Low'
        END AS feature_complexity,
        
        -- Premium feature flag
        CASE 
            WHEN UPPER(fb.feature_name) LIKE '%PREMIUM%' OR UPPER(fb.feature_name) LIKE '%ENTERPRISE%' 
                 OR UPPER(fb.feature_name) LIKE '%ADVANCED%' OR UPPER(fb.feature_name) LIKE '%PRO%' THEN TRUE
            ELSE FALSE
        END AS is_premium_feature,
        
        -- Usage frequency category (based on typical patterns)
        CASE 
            WHEN UPPER(fb.feature_name) LIKE '%VIDEO%' OR UPPER(fb.feature_name) LIKE '%AUDIO%' THEN 'High'
            WHEN UPPER(fb.feature_name) LIKE '%CHAT%' OR UPPER(fb.feature_name) LIKE '%SCREEN%' THEN 'Medium'
            ELSE 'Low'
        END AS usage_frequency_category,
        
        -- Feature status
        'Active' AS feature_status,
        
        -- Target user type
        CASE 
            WHEN UPPER(fb.feature_name) LIKE '%ENTERPRISE%' OR UPPER(fb.feature_name) LIKE '%ADMIN%' THEN 'Enterprise'
            WHEN UPPER(fb.feature_name) LIKE '%BUSINESS%' OR UPPER(fb.feature_name) LIKE '%TEAM%' THEN 'Business'
            WHEN UPPER(fb.feature_name) LIKE '%PRO%' OR UPPER(fb.feature_name) LIKE '%PROFESSIONAL%' THEN 'Professional'
            ELSE 'All Users'
        END AS target_user_type
        
    FROM feature_base fb
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY feature_name) AS feature_id,
    feature_name,
    feature_category,
    feature_type,
    feature_complexity,
    is_premium_feature,
    
    -- Default release date (estimated)
    CAST('2020-01-01' AS DATE) AS feature_release_date,
    
    feature_status,
    usage_frequency_category,
    
    -- Feature description (generated based on category)
    CASE 
        WHEN feature_category = 'Video' THEN 'Video communication and visual collaboration feature'
        WHEN feature_category = 'Audio' THEN 'Audio communication and sound management feature'
        WHEN feature_category = 'Screen Sharing' THEN 'Screen sharing and presentation feature'
        WHEN feature_category = 'Communication' THEN 'Text-based communication and messaging feature'
        WHEN feature_category = 'Recording' THEN 'Meeting recording and playback feature'
        WHEN feature_category = 'Collaboration' THEN 'Team collaboration and workspace feature'
        WHEN feature_category = 'File Management' THEN 'File sharing and document management feature'
        WHEN feature_category = 'Engagement' THEN 'User engagement and interaction feature'
        ELSE 'General platform feature'
    END AS feature_description,
    
    target_user_type,
    
    -- Platform availability (default to all platforms)
    'Web, Desktop, Mobile' AS platform_availability,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_GOLD_PIPELINE' AS source_system
    
FROM feature_enriched
ORDER BY feature_id
