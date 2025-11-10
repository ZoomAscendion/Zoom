-- =====================================================
-- FEATURE DIMENSION TABLE
-- Model: go_dim_feature
-- Purpose: Platform features dimension with usage characteristics
-- Materialization: table
-- Dependencies: go_audit_log
-- =====================================================

{{ config(
    materialized='table',
    cluster_by=['FEATURE_CATEGORY', 'LOAD_DATE'],
    tags=['dimension', 'feature'],
    unique_key='FEATURE_ID'
) }}

-- Extract unique features from Silver layer
WITH source_features AS (
    SELECT DISTINCT 
        FEATURE_NAME,
        MIN(LOAD_DATE) AS FIRST_SEEN_DATE,
        MAX(UPDATE_DATE) AS LAST_UPDATED_DATE,
        COUNT(*) AS USAGE_FREQUENCY,
        AVG(DATA_QUALITY_SCORE) AS AVG_QUALITY_SCORE
    FROM {{ source('silver', 'SI_FEATURE_USAGE') }}
    WHERE VALIDATION_STATUS = '{{ var("validation_status") }}'
      AND DATA_QUALITY_SCORE >= {{ var('min_data_quality_score') }}
      AND FEATURE_NAME IS NOT NULL
      AND TRIM(FEATURE_NAME) != ''
    GROUP BY FEATURE_NAME
),

-- Categorize and enrich features
feature_enrichment AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY FEATURE_NAME) AS FEATURE_ID,
        FEATURE_NAME,
        
        -- Feature categorization based on name patterns
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%SHARE%SCREEN%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%RECORDING%' THEN 'Recording'
            WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' OR UPPER(FEATURE_NAME) LIKE '%MESSAGE%' THEN 'Communication'
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%ROOM%' THEN 'Meeting Management'
            WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' OR UPPER(FEATURE_NAME) LIKE '%ANNOTATION%' THEN 'Collaboration'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' OR UPPER(FEATURE_NAME) LIKE '%SURVEY%' THEN 'Engagement'
            WHEN UPPER(FEATURE_NAME) LIKE '%VIDEO%' OR UPPER(FEATURE_NAME) LIKE '%CAMERA%' THEN 'Video'
            WHEN UPPER(FEATURE_NAME) LIKE '%AUDIO%' OR UPPER(FEATURE_NAME) LIKE '%MIC%' OR UPPER(FEATURE_NAME) LIKE '%SOUND%' THEN 'Audio'
            WHEN UPPER(FEATURE_NAME) LIKE '%FILE%' OR UPPER(FEATURE_NAME) LIKE '%DOCUMENT%' THEN 'File Sharing'
            WHEN UPPER(FEATURE_NAME) LIKE '%SECURITY%' OR UPPER(FEATURE_NAME) LIKE '%PASSWORD%' THEN 'Security'
            WHEN UPPER(FEATURE_NAME) LIKE '%WAITING%' OR UPPER(FEATURE_NAME) LIKE '%LOBBY%' THEN 'Meeting Management'
            ELSE 'Other'
        END AS FEATURE_CATEGORY,
        
        -- Feature type classification
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('AUDIO', 'VIDEO', 'CHAT', 'SCREEN_SHARE', 'MUTE', 'UNMUTE') THEN 'Core'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Advanced'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' OR UPPER(FEATURE_NAME) LIKE '%ANNOTATION%' THEN 'Premium'
            ELSE 'Standard'
        END AS FEATURE_TYPE,
        
        -- Feature complexity assessment
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('AUDIO', 'VIDEO', 'CHAT', 'MUTE', 'UNMUTE') THEN 'Low'
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' OR UPPER(FEATURE_NAME) LIKE '%FILE%' THEN 'Medium'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'High'
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' OR UPPER(FEATURE_NAME) LIKE '%SECURITY%' THEN 'High'
            ELSE 'Medium'
        END AS FEATURE_COMPLEXITY,
        
        -- Premium feature flag
        CASE 
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' 
                OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' 
                OR UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%'
                OR UPPER(FEATURE_NAME) LIKE '%POLL%'
                OR UPPER(FEATURE_NAME) LIKE '%ANNOTATION%'
                OR UPPER(FEATURE_NAME) LIKE '%WAITING%ROOM%'
            THEN TRUE
            ELSE FALSE
        END AS IS_PREMIUM_FEATURE,
        
        -- Feature release date (estimated based on complexity)
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('AUDIO', 'VIDEO', 'CHAT') THEN '2020-01-01'::DATE
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN '2020-03-01'::DATE
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN '2020-06-01'::DATE
            WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN '2020-09-01'::DATE
            WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN '2021-01-01'::DATE
            WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN '2021-03-01'::DATE
            ELSE FIRST_SEEN_DATE
        END AS FEATURE_RELEASE_DATE,
        
        -- Feature status
        CASE 
            WHEN LAST_UPDATED_DATE >= CURRENT_DATE() - 30 THEN 'Active'
            WHEN LAST_UPDATED_DATE >= CURRENT_DATE() - 90 THEN 'Stable'
            WHEN LAST_UPDATED_DATE >= CURRENT_DATE() - 180 THEN 'Maintenance'
            ELSE 'Legacy'
        END AS FEATURE_STATUS,
        
        -- Usage frequency category
        CASE 
            WHEN USAGE_FREQUENCY >= 1000 THEN 'Very High'
            WHEN USAGE_FREQUENCY >= 500 THEN 'High'
            WHEN USAGE_FREQUENCY >= 100 THEN 'Medium'
            WHEN USAGE_FREQUENCY >= 10 THEN 'Low'
            ELSE 'Very Low'
        END AS USAGE_FREQUENCY_CATEGORY,
        
        -- Feature description (generated based on category and type)
        CASE 
            WHEN FEATURE_CATEGORY = 'Audio' THEN 'Audio communication feature for voice interaction'
            WHEN FEATURE_CATEGORY = 'Video' THEN 'Video communication feature for visual interaction'
            WHEN FEATURE_CATEGORY = 'Communication' THEN 'Text-based communication and messaging feature'
            WHEN FEATURE_CATEGORY = 'Collaboration' THEN 'Collaborative feature for content sharing and interaction'
            WHEN FEATURE_CATEGORY = 'Recording' THEN 'Meeting recording and playback feature'
            WHEN FEATURE_CATEGORY = 'Meeting Management' THEN 'Feature for managing meeting flow and participants'
            WHEN FEATURE_CATEGORY = 'Engagement' THEN 'Interactive feature for participant engagement'
            WHEN FEATURE_CATEGORY = 'File Sharing' THEN 'Feature for sharing and managing files'
            WHEN FEATURE_CATEGORY = 'Security' THEN 'Security and access control feature'
            ELSE 'Platform feature for enhanced meeting experience'
        END AS FEATURE_DESCRIPTION,
        
        -- Target user type
        CASE 
            WHEN IS_PREMIUM_FEATURE THEN 'Business/Enterprise'
            WHEN FEATURE_COMPLEXITY = 'High' THEN 'Advanced Users'
            WHEN FEATURE_COMPLEXITY = 'Low' THEN 'All Users'
            ELSE 'Standard Users'
        END AS TARGET_USER_TYPE,
        
        -- Platform availability
        CASE 
            WHEN UPPER(FEATURE_NAME) IN ('AUDIO', 'VIDEO', 'CHAT') THEN 'All Platforms'
            WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Desktop/Mobile'
            WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Desktop/Web'
            WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Desktop/Tablet'
            ELSE 'Desktop/Web/Mobile'
        END AS PLATFORM_AVAILABILITY,
        
        -- Source data attributes
        FIRST_SEEN_DATE,
        LAST_UPDATED_DATE,
        USAGE_FREQUENCY,
        AVG_QUALITY_SCORE
        
    FROM source_features
),

-- Add data quality validation
validated_features AS (
    SELECT 
        *,
        -- Data quality validation
        CASE 
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'FAILED'
            WHEN FEATURE_CATEGORY = 'Other' AND FEATURE_TYPE = 'Standard' THEN 'WARNING'
            WHEN AVG_QUALITY_SCORE < {{ var('min_data_quality_score') }} THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        
        CASE 
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 0
            WHEN FEATURE_CATEGORY = 'Other' AND FEATURE_TYPE = 'Standard' THEN 85
            WHEN AVG_QUALITY_SCORE < {{ var('min_data_quality_score') }} THEN 75
            ELSE 100
        END AS DATA_QUALITY_SCORE
        
    FROM feature_enrichment
)

-- Final select with error handling
SELECT 
    FEATURE_ID,
    FEATURE_NAME,
    FEATURE_CATEGORY,
    FEATURE_TYPE,
    FEATURE_COMPLEXITY,
    IS_PREMIUM_FEATURE,
    FEATURE_RELEASE_DATE,
    FEATURE_STATUS,
    USAGE_FREQUENCY_CATEGORY,
    FEATURE_DESCRIPTION,
    TARGET_USER_TYPE,
    PLATFORM_AVAILABILITY,
    
    -- Standard metadata columns
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'DBT_GOLD_PIPELINE' AS SOURCE_SYSTEM
    
FROM validated_features
WHERE VALIDATION_STATUS = 'PASSED'
   OR (VALIDATION_STATUS = 'WARNING' AND DATA_QUALITY_SCORE >= {{ var('min_data_quality_score') }})
ORDER BY FEATURE_CATEGORY, FEATURE_NAME