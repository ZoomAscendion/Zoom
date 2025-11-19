{{ config(
    materialized='table',
    schema='gold',
    tags=['dimension', 'feature'],
    unique_key='feature_id'
) }}

-- Feature dimension table for Gold layer
-- Contains comprehensive feature metadata and categorization

WITH source_features AS (
    SELECT DISTINCT
        FEATURE_NAME,
        MIN(USAGE_DATE) AS first_usage_date,
        MAX(USAGE_DATE) AS last_usage_date,
        COUNT(DISTINCT MEETING_ID) AS total_meetings_used,
        SUM(USAGE_COUNT) AS total_usage_count,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'SI_FEATURE_USAGE') }}
    WHERE VALIDATION_STATUS = 'VALID'
        AND DATA_QUALITY_SCORE >= 0.7
    GROUP BY FEATURE_NAME, SOURCE_SYSTEM
),

feature_transformations AS (
    SELECT 
        -- Generate surrogate key
        {{ dbt_utils.generate_surrogate_key(['FEATURE_NAME']) }} AS feature_id,
        
        -- Standardized feature name
        INITCAP(TRIM(FEATURE_NAME)) AS feature_name,
        
        -- Feature categorization based on name patterns
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%SCREEN%' THEN 'Screen Sharing'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%MESSAGE%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%ROOM%' THEN 'Meeting Management'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' OR UPPER(FEATURE_NAME) LIKE '%SURVEY%' THEN 'Engagement'
            WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' OR UPPER(FEATURE_NAME) LIKE '%ANNOTATION%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MICROPHONE%' OR UPPER(FEATURE_NAME) LIKE '%MIC%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%FILE%' OR UPPER(FEATURE_NAME) LIKE '%DOCUMENT%' THEN 'File Sharing'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' OR UPPER(FEATURE_NAME) LIKE '%LOCK%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        
        -- Feature type classification
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' OR UPPER(FEATURE_NAME) LIKE '%STANDARD%' THEN 'Core'
            WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' OR UPPER(FEATURE_NAME) LIKE '%PRO%' THEN 'Advanced'
            WHEN UPPER(FEATURE_NAME) LIKE '%PREMIUM%' OR UPPER(FEATURE_NAME) LIKE '%ENTERPRISE%' THEN 'Premium'
            ELSE 'Core'
        END AS feature_type,
        
        -- Feature complexity scoring
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('AUDIO', 'VIDEO', 'CHAT', 'MUTE', 'UNMUTE') THEN 'Low'
            WHEN UPPER(FEATURE_NAME) LIKE '%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Medium'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'High'
            ELSE 'Medium'
        END AS feature_complexity,
        
        -- Premium feature indicator
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR 
                 UPPER(FEATURE_NAME) LIKE '%RECORD%' OR 
                 UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' OR
                 UPPER(FEATURE_NAME) LIKE '%POLL%' OR
                 UPPER(FEATURE_NAME) LIKE '%WEBINAR%' THEN TRUE
            ELSE FALSE
        END AS is_premium_feature,
        
        -- Feature release date (using first usage as proxy)
        first_usage_date AS feature_release_date,
        
        -- Feature status based on recent usage
        CASE 
            WHEN last_usage_date >= CURRENT_DATE() - INTERVAL '30 days' THEN 'Active'
            WHEN last_usage_date >= CURRENT_DATE() - INTERVAL '90 days' THEN 'Low Usage'
            ELSE 'Deprecated'
        END AS feature_status,
        
        -- Usage frequency categorization
        CASE 
            WHEN total_usage_count >= 1000 THEN 'High'
            WHEN total_usage_count >= 100 THEN 'Medium'
            WHEN total_usage_count >= 10 THEN 'Low'
            ELSE 'Minimal'
        END AS usage_frequency_category,
        
        -- Feature description (generated based on name)
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Allows users to share their screen content with meeting participants'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Enables recording of meeting audio, video, and screen sharing'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Provides text-based communication during meetings'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Creates separate meeting rooms for smaller group discussions'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Allows hosts to create interactive polls for participant engagement'
            WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Provides collaborative whiteboard functionality for visual collaboration'
            ELSE 'Zoom platform feature for enhanced meeting experience'
        END AS feature_description,
        
        -- Target user segment
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('AUDIO', 'VIDEO', 'CHAT', 'MUTE') THEN 'All Users'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%' THEN 'Business Users'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Enterprise Users'
            ELSE 'Business Users'
        END AS target_user_segment,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        SOURCE_SYSTEM AS source_system
        
    FROM source_features
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
    target_user_segment,
    load_date,
    update_date,
    source_system
FROM feature_transformations
ORDER BY feature_name