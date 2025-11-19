{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['dimension', 'feature']
) }}

-- Feature dimension table
-- Contains comprehensive feature metadata and categorization

WITH source_features AS (
    SELECT DISTINCT
        feature_name,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver_layer', 'si_feature_usage') }}
    WHERE validation_status = 'VALID'
      AND feature_name IS NOT NULL
      AND TRIM(feature_name) != ''
),

feature_enrichment AS (
    SELECT 
        TRIM(feature_name) AS feature_name,
        
        -- Feature categorization based on name patterns
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%SHARE%SCREEN%' THEN 'Screen Sharing'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(feature_name) LIKE '%CHAT%' OR UPPER(feature_name) LIKE '%MESSAGE%' THEN 'Communication'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%ROOM%' THEN 'Meeting Management'
            WHEN UPPER(feature_name) LIKE '%POLL%' OR UPPER(feature_name) LIKE '%SURVEY%' THEN 'Engagement'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%ANNOTATION%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%AUDIO%' OR UPPER(feature_name) LIKE '%MICROPHONE%' OR UPPER(feature_name) LIKE '%MIC%' THEN 'Audio'
            WHEN UPPER(feature_name) LIKE '%VIDEO%' OR UPPER(feature_name) LIKE '%CAMERA%' OR UPPER(feature_name) LIKE '%CAM%' THEN 'Video'
            WHEN UPPER(feature_name) LIKE '%FILE%' OR UPPER(feature_name) LIKE '%DOCUMENT%' OR UPPER(feature_name) LIKE '%UPLOAD%' THEN 'File Management'
            WHEN UPPER(feature_name) LIKE '%SECURITY%' OR UPPER(feature_name) LIKE '%PASSWORD%' OR UPPER(feature_name) LIKE '%LOCK%' THEN 'Security'
            ELSE 'Other'
        END AS feature_category,
        
        -- Feature type classification
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%RECORD%' 
                 OR UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Core'
            WHEN UPPER(feature_name) LIKE '%POLL%' OR UPPER(feature_name) LIKE '%BREAKOUT%' 
                 OR UPPER(feature_name) LIKE '%ANNOTATION%' THEN 'Advanced'
            WHEN UPPER(feature_name) LIKE '%SECURITY%' OR UPPER(feature_name) LIKE '%ADMIN%' THEN 'Administrative'
            ELSE 'Basic'
        END AS feature_type,
        
        -- Feature complexity scoring
        CASE 
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%POLL%' 
                 OR UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%RECORD%' THEN 'High'
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%FILE%' 
                 OR UPPER(feature_name) LIKE '%ANNOTATION%' THEN 'Medium'
            ELSE 'Low'
        END AS feature_complexity,
        
        -- Premium feature flag
        CASE 
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%BREAKOUT%' 
                 OR UPPER(feature_name) LIKE '%POLL%' OR UPPER(feature_name) LIKE '%WHITEBOARD%' 
                 OR UPPER(feature_name) LIKE '%ADMIN%' OR UPPER(feature_name) LIKE '%SECURITY%' THEN TRUE
            ELSE FALSE
        END AS is_premium_feature,
        
        -- Feature release date (estimated based on feature type)
        CASE 
            WHEN UPPER(feature_name) LIKE '%CHAT%' OR UPPER(feature_name) LIKE '%AUDIO%' 
                 OR UPPER(feature_name) LIKE '%VIDEO%' THEN '2020-01-01'::DATE
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%RECORD%' THEN '2020-06-01'::DATE
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%POLL%' THEN '2021-01-01'::DATE
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%ANNOTATION%' THEN '2021-06-01'::DATE
            ELSE '2020-01-01'::DATE
        END AS feature_release_date,
        
        -- Feature status
        'Active' AS feature_status,
        
        -- Usage frequency category (estimated)
        CASE 
            WHEN UPPER(feature_name) LIKE '%AUDIO%' OR UPPER(feature_name) LIKE '%VIDEO%' 
                 OR UPPER(feature_name) LIKE '%CHAT%' THEN 'Very High'
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%RECORD%' THEN 'High'
            WHEN UPPER(feature_name) LIKE '%FILE%' OR UPPER(feature_name) LIKE '%POLL%' THEN 'Medium'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Low'
            ELSE 'Medium'
        END AS usage_frequency_category,
        
        -- Feature description
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Share computer screen with meeting participants'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Record meeting audio and video for later playback'
            WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Send text messages during meetings'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Create separate meeting rooms for small group discussions'
            WHEN UPPER(feature_name) LIKE '%POLL%' THEN 'Conduct live polls and surveys during meetings'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Collaborative digital whiteboard for visual collaboration'
            WHEN UPPER(feature_name) LIKE '%FILE%' THEN 'Share and manage files during meetings'
            WHEN UPPER(feature_name) LIKE '%AUDIO%' THEN 'Audio communication capabilities'
            WHEN UPPER(feature_name) LIKE '%VIDEO%' THEN 'Video communication capabilities'
            ELSE 'Zoom platform feature'
        END AS feature_description,
        
        -- Target user segment
        CASE 
            WHEN UPPER(feature_name) LIKE '%ADMIN%' OR UPPER(feature_name) LIKE '%SECURITY%' THEN 'Administrators'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%POLL%' 
                 OR UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Educators & Trainers'
            WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Business Users'
            ELSE 'All Users'
        END AS target_user_segment,
        
        -- Audit fields
        source_system,
        load_date,
        update_date
        
    FROM source_features
)

SELECT 
    MD5(UPPER(TRIM(feature_name))) AS feature_id,
    INITCAP(feature_name) AS feature_name,
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
FROM feature_enrichment
ORDER BY feature_name