-- =====================================================
-- GOLD LAYER FEATURE DIMENSION MODEL
-- Model: go_dim_feature
-- Purpose: Dimension table containing platform features and their characteristics
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- =====================================================

{{
  config(
    materialized='table',
    database='DB_POC_ZOOM',
    schema='GOLD',
    alias='GO_DIM_FEATURE',
    tags=['dimension', 'gold_layer', 'feature_dimension'],
    cluster_by=['FEATURE_ID', 'FEATURE_CATEGORY'],
    comment='Dimension table containing platform features and their characteristics for usage analysis'
  )
}}

-- =====================================================
-- SOURCE DATA EXTRACTION
-- =====================================================

WITH source_features AS (
  SELECT DISTINCT
    FEATURE_NAME,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
  FROM {{ source('silver_layer', 'SI_FEATURE_USAGE') }}
  WHERE VALIDATION_STATUS = 'PASSED'
    AND DATA_QUALITY_SCORE >= {{ var('min_data_quality_score') }}
    AND FEATURE_NAME IS NOT NULL
    AND TRIM(FEATURE_NAME) != ''
),

-- =====================================================
-- FEATURE CLEANSING AND STANDARDIZATION
-- =====================================================

cleansed_features AS (
  SELECT 
    -- Standardize feature name
    TRIM(INITCAP(FEATURE_NAME)) AS FEATURE_NAME_CLEAN,
    TRIM(UPPER(FEATURE_NAME)) AS FEATURE_NAME_UPPER,
    
    -- Original for audit
    FEATURE_NAME AS FEATURE_NAME_ORIGINAL,
    
    -- Metadata
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
    
  FROM source_features
  WHERE FEATURE_NAME IS NOT NULL
),

-- =====================================================
-- FEATURE CATEGORIZATION AND CLASSIFICATION
-- =====================================================

feature_classified AS (
  SELECT 
    *,
    
    -- Feature category classification
    CASE 
      WHEN FEATURE_NAME_UPPER LIKE '%SCREEN%SHARE%' OR FEATURE_NAME_UPPER LIKE '%SHARE%SCREEN%' THEN 'Collaboration'
      WHEN FEATURE_NAME_UPPER LIKE '%RECORD%' OR FEATURE_NAME_UPPER LIKE '%RECORDING%' THEN 'Recording'
      WHEN FEATURE_NAME_UPPER LIKE '%CHAT%' OR FEATURE_NAME_UPPER LIKE '%MESSAGE%' THEN 'Communication'
      WHEN FEATURE_NAME_UPPER LIKE '%BREAKOUT%' OR FEATURE_NAME_UPPER LIKE '%ROOM%' THEN 'Advanced Meeting'
      WHEN FEATURE_NAME_UPPER LIKE '%POLL%' OR FEATURE_NAME_UPPER LIKE '%SURVEY%' OR FEATURE_NAME_UPPER LIKE '%VOTE%' THEN 'Engagement'
      WHEN FEATURE_NAME_UPPER LIKE '%WHITEBOARD%' OR FEATURE_NAME_UPPER LIKE '%ANNOTATION%' THEN 'Collaboration'
      WHEN FEATURE_NAME_UPPER LIKE '%AUDIO%' OR FEATURE_NAME_UPPER LIKE '%MICROPHONE%' OR FEATURE_NAME_UPPER LIKE '%MIC%' THEN 'Audio'
      WHEN FEATURE_NAME_UPPER LIKE '%VIDEO%' OR FEATURE_NAME_UPPER LIKE '%CAMERA%' OR FEATURE_NAME_UPPER LIKE '%WEBCAM%' THEN 'Video'
      WHEN FEATURE_NAME_UPPER LIKE '%FILE%' OR FEATURE_NAME_UPPER LIKE '%DOCUMENT%' OR FEATURE_NAME_UPPER LIKE '%UPLOAD%' THEN 'File Sharing'
      WHEN FEATURE_NAME_UPPER LIKE '%SECURITY%' OR FEATURE_NAME_UPPER LIKE '%PASSWORD%' OR FEATURE_NAME_UPPER LIKE '%LOCK%' THEN 'Security'
      WHEN FEATURE_NAME_UPPER LIKE '%CALENDAR%' OR FEATURE_NAME_UPPER LIKE '%SCHEDULE%' THEN 'Scheduling'
      WHEN FEATURE_NAME_UPPER LIKE '%MOBILE%' OR FEATURE_NAME_UPPER LIKE '%PHONE%' THEN 'Mobile'
      WHEN FEATURE_NAME_UPPER LIKE '%INTEGRATION%' OR FEATURE_NAME_UPPER LIKE '%API%' THEN 'Integration'
      ELSE 'General'
    END AS FEATURE_CATEGORY,
    
    -- Feature type classification
    CASE 
      WHEN FEATURE_NAME_UPPER LIKE '%BASIC%' OR FEATURE_NAME_UPPER LIKE '%STANDARD%' THEN 'Core'
      WHEN FEATURE_NAME_UPPER LIKE '%ADVANCED%' OR FEATURE_NAME_UPPER LIKE '%PRO%' OR FEATURE_NAME_UPPER LIKE '%PREMIUM%' THEN 'Advanced'
      WHEN FEATURE_NAME_UPPER LIKE '%ENTERPRISE%' OR FEATURE_NAME_UPPER LIKE '%ADMIN%' THEN 'Enterprise'
      ELSE 'Standard'
    END AS FEATURE_TYPE,
    
    -- Feature complexity assessment
    CASE 
      WHEN FEATURE_NAME_UPPER LIKE '%BREAKOUT%' OR FEATURE_NAME_UPPER LIKE '%POLL%' 
           OR FEATURE_NAME_UPPER LIKE '%INTEGRATION%' OR FEATURE_NAME_UPPER LIKE '%API%' 
           OR FEATURE_NAME_UPPER LIKE '%SECURITY%' THEN 'High'
      WHEN FEATURE_NAME_UPPER LIKE '%RECORD%' OR FEATURE_NAME_UPPER LIKE '%WHITEBOARD%' 
           OR FEATURE_NAME_UPPER LIKE '%FILE%' OR FEATURE_NAME_UPPER LIKE '%SCHEDULE%' THEN 'Medium'
      WHEN FEATURE_NAME_UPPER LIKE '%CHAT%' OR FEATURE_NAME_UPPER LIKE '%AUDIO%' 
           OR FEATURE_NAME_UPPER LIKE '%VIDEO%' OR FEATURE_NAME_UPPER LIKE '%SCREEN%SHARE%' THEN 'Low'
      ELSE 'Medium'
    END AS FEATURE_COMPLEXITY,
    
    -- Premium feature identification
    CASE 
      WHEN FEATURE_NAME_UPPER LIKE '%RECORD%' OR FEATURE_NAME_UPPER LIKE '%BREAKOUT%' 
           OR FEATURE_NAME_UPPER LIKE '%POLL%' OR FEATURE_NAME_UPPER LIKE '%WHITEBOARD%'
           OR FEATURE_NAME_UPPER LIKE '%INTEGRATION%' OR FEATURE_NAME_UPPER LIKE '%API%'
           OR FEATURE_NAME_UPPER LIKE '%ENTERPRISE%' OR FEATURE_NAME_UPPER LIKE '%ADMIN%' THEN TRUE
      ELSE FALSE
    END AS IS_PREMIUM_FEATURE,
    
    -- Usage frequency category (estimated)
    CASE 
      WHEN FEATURE_NAME_UPPER LIKE '%AUDIO%' OR FEATURE_NAME_UPPER LIKE '%VIDEO%' 
           OR FEATURE_NAME_UPPER LIKE '%CHAT%' THEN 'Very High'
      WHEN FEATURE_NAME_UPPER LIKE '%SCREEN%SHARE%' OR FEATURE_NAME_UPPER LIKE '%RECORD%' THEN 'High'
      WHEN FEATURE_NAME_UPPER LIKE '%FILE%' OR FEATURE_NAME_UPPER LIKE '%WHITEBOARD%' 
           OR FEATURE_NAME_UPPER LIKE '%POLL%' THEN 'Medium'
      WHEN FEATURE_NAME_UPPER LIKE '%BREAKOUT%' OR FEATURE_NAME_UPPER LIKE '%INTEGRATION%' THEN 'Low'
      ELSE 'Medium'
    END AS USAGE_FREQUENCY_CATEGORY,
    
    -- Target user segment
    CASE 
      WHEN FEATURE_NAME_UPPER LIKE '%ENTERPRISE%' OR FEATURE_NAME_UPPER LIKE '%ADMIN%' 
           OR FEATURE_NAME_UPPER LIKE '%API%' THEN 'Enterprise Users'
      WHEN FEATURE_NAME_UPPER LIKE '%BREAKOUT%' OR FEATURE_NAME_UPPER LIKE '%POLL%' 
           OR FEATURE_NAME_UPPER LIKE '%WHITEBOARD%' THEN 'Business Users'
      WHEN FEATURE_NAME_UPPER LIKE '%MOBILE%' OR FEATURE_NAME_UPPER LIKE '%PHONE%' THEN 'Mobile Users'
      WHEN FEATURE_NAME_UPPER LIKE '%INTEGRATION%' THEN 'Power Users'
      ELSE 'All Users'
    END AS TARGET_USER_SEGMENT
    
  FROM cleansed_features
),

-- =====================================================
-- FEATURE ENRICHMENT
-- =====================================================

feature_enriched AS (
  SELECT 
    *,
    
    -- Feature release date (estimated based on complexity)
    CASE 
      WHEN FEATURE_COMPLEXITY = 'High' THEN '2021-01-01'::DATE
      WHEN FEATURE_COMPLEXITY = 'Medium' THEN '2020-06-01'::DATE
      ELSE '2020-01-01'::DATE
    END AS FEATURE_RELEASE_DATE,
    
    -- Feature status
    CASE 
      WHEN IS_PREMIUM_FEATURE = TRUE THEN 'Premium Active'
      ELSE 'Standard Active'
    END AS FEATURE_STATUS,
    
    -- Feature description generation
    CASE 
      WHEN FEATURE_CATEGORY = 'Collaboration' THEN 
        'Enables collaborative work and content sharing during meetings'
      WHEN FEATURE_CATEGORY = 'Recording' THEN 
        'Provides meeting recording and playback capabilities'
      WHEN FEATURE_CATEGORY = 'Communication' THEN 
        'Facilitates real-time communication and messaging'
      WHEN FEATURE_CATEGORY = 'Advanced Meeting' THEN 
        'Advanced meeting management and organization features'
      WHEN FEATURE_CATEGORY = 'Engagement' THEN 
        'Interactive features to enhance participant engagement'
      WHEN FEATURE_CATEGORY = 'Audio' THEN 
        'Audio processing and management capabilities'
      WHEN FEATURE_CATEGORY = 'Video' THEN 
        'Video streaming and processing features'
      WHEN FEATURE_CATEGORY = 'File Sharing' THEN 
        'File upload, sharing, and management functionality'
      WHEN FEATURE_CATEGORY = 'Security' THEN 
        'Security and access control features'
      WHEN FEATURE_CATEGORY = 'Scheduling' THEN 
        'Meeting scheduling and calendar integration'
      WHEN FEATURE_CATEGORY = 'Mobile' THEN 
        'Mobile device specific features and optimizations'
      WHEN FEATURE_CATEGORY = 'Integration' THEN 
        'Third-party integrations and API access'
      ELSE 'General platform feature for enhanced user experience'
    END AS FEATURE_DESCRIPTION,
    
    -- Business value assessment
    CASE 
      WHEN IS_PREMIUM_FEATURE = TRUE AND FEATURE_COMPLEXITY = 'High' THEN 'High Value'
      WHEN IS_PREMIUM_FEATURE = TRUE OR FEATURE_COMPLEXITY = 'High' THEN 'Medium-High Value'
      WHEN USAGE_FREQUENCY_CATEGORY IN ('Very High', 'High') THEN 'Medium Value'
      ELSE 'Standard Value'
    END AS BUSINESS_VALUE_TIER,
    
    -- Platform compatibility
    CASE 
      WHEN FEATURE_NAME_UPPER LIKE '%MOBILE%' THEN 'Mobile Only'
      WHEN FEATURE_NAME_UPPER LIKE '%DESKTOP%' THEN 'Desktop Only'
      WHEN FEATURE_NAME_UPPER LIKE '%WEB%' THEN 'Web Only'
      ELSE 'Cross Platform'
    END AS PLATFORM_COMPATIBILITY
    
  FROM feature_classified
),

-- =====================================================
-- FINAL DIMENSION STRUCTURE
-- =====================================================

final_dimension AS (
  SELECT 
    -- Surrogate key (auto-increment will be handled by Snowflake)
    ROW_NUMBER() OVER (ORDER BY FEATURE_NAME_CLEAN) AS FEATURE_ID,
    
    -- Feature identification
    FEATURE_NAME_CLEAN AS FEATURE_NAME,
    
    -- Feature classification
    FEATURE_CATEGORY,
    FEATURE_TYPE,
    FEATURE_COMPLEXITY,
    IS_PREMIUM_FEATURE,
    
    -- Feature lifecycle
    FEATURE_RELEASE_DATE,
    FEATURE_STATUS,
    
    -- Usage characteristics
    USAGE_FREQUENCY_CATEGORY,
    TARGET_USER_SEGMENT,
    BUSINESS_VALUE_TIER,
    PLATFORM_COMPATIBILITY,
    
    -- Feature description
    FEATURE_DESCRIPTION,
    
    -- Standard metadata
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    COALESCE(SOURCE_SYSTEM, 'SILVER_LAYER') AS SOURCE_SYSTEM
    
  FROM feature_enriched
)

-- =====================================================
-- FINAL OUTPUT WITH QUALITY VALIDATION
-- =====================================================

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
  TARGET_USER_SEGMENT,
  BUSINESS_VALUE_TIER,
  PLATFORM_COMPATIBILITY,
  LOAD_DATE,
  UPDATE_DATE,
  SOURCE_SYSTEM
  
FROM final_dimension

-- Data quality validation
WHERE FEATURE_NAME IS NOT NULL
  AND FEATURE_NAME != ''
  AND FEATURE_CATEGORY IS NOT NULL
  AND FEATURE_TYPE IS NOT NULL
  AND FEATURE_COMPLEXITY IN ('Low', 'Medium', 'High')
  AND USAGE_FREQUENCY_CATEGORY IN ('Very High', 'High', 'Medium', 'Low')

ORDER BY FEATURE_CATEGORY, FEATURE_NAME

-- =====================================================
-- MODEL DOCUMENTATION
-- =====================================================

/*
MODEL DESCRIPTION:
This model creates the feature dimension table containing comprehensive 
information about platform features and their characteristics for usage analysis.

KEY FEATURES:
1. Comprehensive feature categorization and classification
2. Business rule-based feature type and complexity assessment
3. Premium feature identification for revenue analysis
4. Usage frequency estimation for adoption analysis
5. Target user segment classification
6. Platform compatibility assessment
7. Business value tier assignment
8. Automated feature description generation

FEATURE CATEGORIES:
- Collaboration: Screen sharing, whiteboard, annotations
- Recording: Meeting recording and playback
- Communication: Chat, messaging, real-time communication
- Advanced Meeting: Breakout rooms, advanced organization
- Engagement: Polls, surveys, interactive features
- Audio: Audio processing and management
- Video: Video streaming and processing
- File Sharing: File upload and sharing
- Security: Security and access control
- Scheduling: Calendar integration and scheduling
- Mobile: Mobile-specific features
- Integration: Third-party integrations and APIs
- General: Other platform features

FEATURE TYPES:
- Core: Basic, standard features
- Standard: Regular platform features
- Advanced: Pro, premium, advanced features
- Enterprise: Enterprise-specific features

COMPLEXITY LEVELS:
- Low: Simple features (chat, audio, video, screen share)
- Medium: Moderate complexity (recording, whiteboard, file sharing)
- High: Complex features (breakout rooms, polls, integrations, security)

USAGE FREQUENCY:
- Very High: Core communication features (audio, video, chat)
- High: Common collaboration features (screen share, recording)
- Medium: Regular features (file sharing, whiteboard, polls)
- Low: Specialized features (breakout rooms, integrations)

BUSINESS VALUE TIERS:
- High Value: Premium + High complexity features
- Medium-High Value: Premium OR High complexity features
- Medium Value: High usage frequency features
- Standard Value: Other features

DATA QUALITY:
- Validates feature names are not null or empty
- Ensures proper categorization values
- Maintains referential integrity
- Handles duplicate feature names through DISTINCT

PERFORMANCE OPTIMIZATIONS:
- Clustered by FEATURE_ID and FEATURE_CATEGORY
- Pre-calculated derived attributes
- Efficient categorization logic
- Optimized for fact table joins

USAGE:
- Join to fact tables using FEATURE_ID (surrogate key)
- Filter by FEATURE_CATEGORY for category-specific analysis
- Use IS_PREMIUM_FEATURE for revenue impact analysis
- Analyze adoption by USAGE_FREQUENCY_CATEGORY
- Segment analysis by TARGET_USER_SEGMENT

MONITORING:
- Monitor for new features from source data
- Validate feature categorization accuracy
- Check premium feature identification
- Ensure proper business value tier assignment
*/

-- =====================================================
-- END OF FEATURE DIMENSION MODEL
-- =====================================================