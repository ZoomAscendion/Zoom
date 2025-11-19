-- =====================================================
-- GOLD LAYER MEETING TYPE DIMENSION MODEL
-- Model: go_dim_meeting_type
-- Purpose: Dimension table containing meeting types and characteristics
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- =====================================================

{{
  config(
    materialized='table',
    database='DB_POC_ZOOM',
    schema='GOLD',
    alias='GO_DIM_MEETING_TYPE',
    tags=['dimension', 'gold_layer', 'meeting_type_dimension'],
    cluster_by=['MEETING_TYPE_ID', 'TIME_OF_DAY_CATEGORY'],
    comment='Dimension table containing meeting types and characteristics for meeting analysis'
  )
}}

-- =====================================================
-- SOURCE DATA EXTRACTION AND AGGREGATION
-- =====================================================

WITH source_meetings AS (
  SELECT 
    MEETING_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
  FROM {{ source('silver_layer', 'SI_MEETINGS') }}
  WHERE VALIDATION_STATUS = 'PASSED'
    AND DATA_QUALITY_SCORE >= {{ var('min_data_quality_score') }}
    AND START_TIME IS NOT NULL
    AND DURATION_MINUTES IS NOT NULL
    AND DURATION_MINUTES > 0
),

-- =====================================================
-- MEETING PATTERN ANALYSIS
-- =====================================================

meeting_patterns AS (
  SELECT 
    MEETING_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    
    -- Time-based attributes
    HOUR(START_TIME) AS START_HOUR,
    DAYOFWEEK(START_TIME) AS DAY_OF_WEEK_NUMBER,
    DAYNAME(START_TIME) AS DAY_NAME,
    
    -- Duration categorization
    CASE 
      WHEN DURATION_MINUTES <= 15 THEN 'Brief'
      WHEN DURATION_MINUTES <= 30 THEN 'Short'
      WHEN DURATION_MINUTES <= 60 THEN 'Standard'
      WHEN DURATION_MINUTES <= 120 THEN 'Extended'
      WHEN DURATION_MINUTES <= 240 THEN 'Long'
      ELSE 'Marathon'
    END AS DURATION_CATEGORY,
    
    -- Time of day categorization
    CASE 
      WHEN HOUR(START_TIME) BETWEEN 5 AND 8 THEN 'Early Morning'
      WHEN HOUR(START_TIME) BETWEEN 9 AND 11 THEN 'Morning'
      WHEN HOUR(START_TIME) BETWEEN 12 AND 13 THEN 'Lunch Time'
      WHEN HOUR(START_TIME) BETWEEN 14 AND 17 THEN 'Afternoon'
      WHEN HOUR(START_TIME) BETWEEN 18 AND 20 THEN 'Evening'
      WHEN HOUR(START_TIME) BETWEEN 21 AND 23 THEN 'Late Evening'
      ELSE 'Night'
    END AS TIME_OF_DAY_CATEGORY,
    
    -- Weekend flag
    CASE 
      WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE 
      ELSE FALSE 
    END AS IS_WEEKEND_MEETING,
    
    -- Meeting topic analysis for type detection
    UPPER(COALESCE(MEETING_TOPIC, 'STANDARD MEETING')) AS MEETING_TOPIC_UPPER,
    
    -- Metadata
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
    
  FROM source_meetings
),

-- =====================================================
-- MEETING TYPE CLASSIFICATION
-- =====================================================

meeting_classified AS (
  SELECT 
    *,
    
    -- Meeting type classification based on topic and patterns
    CASE 
      WHEN MEETING_TOPIC_UPPER LIKE '%STANDUP%' OR MEETING_TOPIC_UPPER LIKE '%DAILY%' 
           OR MEETING_TOPIC_UPPER LIKE '%SCRUM%' THEN 'Daily Standup'
      WHEN MEETING_TOPIC_UPPER LIKE '%INTERVIEW%' OR MEETING_TOPIC_UPPER LIKE '%HIRING%' THEN 'Interview'
      WHEN MEETING_TOPIC_UPPER LIKE '%TRAINING%' OR MEETING_TOPIC_UPPER LIKE '%WORKSHOP%' 
           OR MEETING_TOPIC_UPPER LIKE '%EDUCATION%' THEN 'Training/Workshop'
      WHEN MEETING_TOPIC_UPPER LIKE '%DEMO%' OR MEETING_TOPIC_UPPER LIKE '%PRESENTATION%' 
           OR MEETING_TOPIC_UPPER LIKE '%SHOWCASE%' THEN 'Demo/Presentation'
      WHEN MEETING_TOPIC_UPPER LIKE '%REVIEW%' OR MEETING_TOPIC_UPPER LIKE '%RETROSPECTIVE%' 
           OR MEETING_TOPIC_UPPER LIKE '%RETRO%' THEN 'Review/Retrospective'
      WHEN MEETING_TOPIC_UPPER LIKE '%PLANNING%' OR MEETING_TOPIC_UPPER LIKE '%STRATEGY%' 
           OR MEETING_TOPIC_UPPER LIKE '%ROADMAP%' THEN 'Planning/Strategy'
      WHEN MEETING_TOPIC_UPPER LIKE '%1:1%' OR MEETING_TOPIC_UPPER LIKE '%ONE ON ONE%' 
           OR MEETING_TOPIC_UPPER LIKE '%1-ON-1%' THEN 'One-on-One'
      WHEN MEETING_TOPIC_UPPER LIKE '%ALL HANDS%' OR MEETING_TOPIC_UPPER LIKE '%COMPANY%' 
           OR MEETING_TOPIC_UPPER LIKE '%TOWN HALL%' THEN 'All Hands/Company'
      WHEN MEETING_TOPIC_UPPER LIKE '%CLIENT%' OR MEETING_TOPIC_UPPER LIKE '%CUSTOMER%' 
           OR MEETING_TOPIC_UPPER LIKE '%EXTERNAL%' THEN 'Client/External'
      WHEN MEETING_TOPIC_UPPER LIKE '%TEAM%' OR MEETING_TOPIC_UPPER LIKE '%SYNC%' 
           OR MEETING_TOPIC_UPPER LIKE '%CHECK-IN%' THEN 'Team Sync'
      WHEN MEETING_TOPIC_UPPER LIKE '%WEBINAR%' OR MEETING_TOPIC_UPPER LIKE '%SEMINAR%' THEN 'Webinar/Seminar'
      WHEN MEETING_TOPIC_UPPER LIKE '%SOCIAL%' OR MEETING_TOPIC_UPPER LIKE '%HAPPY HOUR%' 
           OR MEETING_TOPIC_UPPER LIKE '%COFFEE%' THEN 'Social/Informal'
      ELSE 'Standard Meeting'
    END AS MEETING_TYPE,
    
    -- Meeting category (higher level grouping)
    CASE 
      WHEN MEETING_TOPIC_UPPER LIKE '%STANDUP%' OR MEETING_TOPIC_UPPER LIKE '%DAILY%' 
           OR MEETING_TOPIC_UPPER LIKE '%SCRUM%' OR MEETING_TOPIC_UPPER LIKE '%SYNC%' THEN 'Operational'
      WHEN MEETING_TOPIC_UPPER LIKE '%INTERVIEW%' OR MEETING_TOPIC_UPPER LIKE '%HIRING%' THEN 'HR/Recruitment'
      WHEN MEETING_TOPIC_UPPER LIKE '%TRAINING%' OR MEETING_TOPIC_UPPER LIKE '%WORKSHOP%' 
           OR MEETING_TOPIC_UPPER LIKE '%EDUCATION%' OR MEETING_TOPIC_UPPER LIKE '%WEBINAR%' THEN 'Learning/Development'
      WHEN MEETING_TOPIC_UPPER LIKE '%DEMO%' OR MEETING_TOPIC_UPPER LIKE '%PRESENTATION%' 
           OR MEETING_TOPIC_UPPER LIKE '%SHOWCASE%' THEN 'Presentation/Demo'
      WHEN MEETING_TOPIC_UPPER LIKE '%REVIEW%' OR MEETING_TOPIC_UPPER LIKE '%RETROSPECTIVE%' 
           OR MEETING_TOPIC_UPPER LIKE '%RETRO%' THEN 'Review/Feedback'
      WHEN MEETING_TOPIC_UPPER LIKE '%PLANNING%' OR MEETING_TOPIC_UPPER LIKE '%STRATEGY%' 
           OR MEETING_TOPIC_UPPER LIKE '%ROADMAP%' THEN 'Strategic Planning'
      WHEN MEETING_TOPIC_UPPER LIKE '%1:1%' OR MEETING_TOPIC_UPPER LIKE '%ONE ON ONE%' THEN 'Personal/1:1'
      WHEN MEETING_TOPIC_UPPER LIKE '%ALL HANDS%' OR MEETING_TOPIC_UPPER LIKE '%COMPANY%' 
           OR MEETING_TOPIC_UPPER LIKE '%TOWN HALL%' THEN 'Company-wide'
      WHEN MEETING_TOPIC_UPPER LIKE '%CLIENT%' OR MEETING_TOPIC_UPPER LIKE '%CUSTOMER%' 
           OR MEETING_TOPIC_UPPER LIKE '%EXTERNAL%' THEN 'External/Client'
      WHEN MEETING_TOPIC_UPPER LIKE '%SOCIAL%' OR MEETING_TOPIC_UPPER LIKE '%HAPPY HOUR%' 
           OR MEETING_TOPIC_UPPER LIKE '%COFFEE%' THEN 'Social/Team Building'
      ELSE 'General Business'
    END AS MEETING_CATEGORY,
    
    -- Participant size category (estimated based on meeting type)
    CASE 
      WHEN MEETING_TOPIC_UPPER LIKE '%1:1%' OR MEETING_TOPIC_UPPER LIKE '%ONE ON ONE%' THEN 'Small (2-3)'
      WHEN MEETING_TOPIC_UPPER LIKE '%STANDUP%' OR MEETING_TOPIC_UPPER LIKE '%SCRUM%' 
           OR MEETING_TOPIC_UPPER LIKE '%TEAM%' THEN 'Medium (4-10)'
      WHEN MEETING_TOPIC_UPPER LIKE '%ALL HANDS%' OR MEETING_TOPIC_UPPER LIKE '%COMPANY%' 
           OR MEETING_TOPIC_UPPER LIKE '%WEBINAR%' THEN 'Large (50+)'
      WHEN MEETING_TOPIC_UPPER LIKE '%TRAINING%' OR MEETING_TOPIC_UPPER LIKE '%WORKSHOP%' THEN 'Medium-Large (10-30)'
      ELSE 'Small-Medium (3-8)'
    END AS PARTICIPANT_SIZE_CATEGORY,
    
    -- Recurring meeting detection (estimated)
    CASE 
      WHEN MEETING_TOPIC_UPPER LIKE '%DAILY%' OR MEETING_TOPIC_UPPER LIKE '%STANDUP%' 
           OR MEETING_TOPIC_UPPER LIKE '%WEEKLY%' OR MEETING_TOPIC_UPPER LIKE '%MONTHLY%' 
           OR MEETING_TOPIC_UPPER LIKE '%1:1%' OR MEETING_TOPIC_UPPER LIKE '%SYNC%' THEN TRUE
      ELSE FALSE
    END AS IS_RECURRING_TYPE
    
  FROM meeting_patterns
),

-- =====================================================
-- MEETING TYPE AGGREGATION AND ENRICHMENT
-- =====================================================

meeting_type_aggregated AS (
  SELECT 
    MEETING_TYPE,
    MEETING_CATEGORY,
    DURATION_CATEGORY,
    PARTICIPANT_SIZE_CATEGORY,
    TIME_OF_DAY_CATEGORY,
    DAY_NAME,
    IS_WEEKEND_MEETING,
    IS_RECURRING_TYPE,
    
    -- Aggregated metrics for quality scoring
    COUNT(*) AS MEETING_COUNT,
    AVG(DURATION_MINUTES) AS AVG_DURATION_MINUTES,
    AVG(DATA_QUALITY_SCORE) AS AVG_DATA_QUALITY_SCORE,
    
    -- Most common values
    MODE(DAY_NAME) AS MOST_COMMON_DAY,
    MODE(TIME_OF_DAY_CATEGORY) AS MOST_COMMON_TIME,
    
    -- Metadata
    MAX(SOURCE_SYSTEM) AS SOURCE_SYSTEM,
    MAX(LOAD_DATE) AS LOAD_DATE,
    MAX(UPDATE_DATE) AS UPDATE_DATE
    
  FROM meeting_classified
  GROUP BY 
    MEETING_TYPE,
    MEETING_CATEGORY,
    DURATION_CATEGORY,
    PARTICIPANT_SIZE_CATEGORY,
    TIME_OF_DAY_CATEGORY,
    DAY_NAME,
    IS_WEEKEND_MEETING,
    IS_RECURRING_TYPE
),

-- =====================================================
-- MEETING TYPE ENRICHMENT
-- =====================================================

meeting_type_enriched AS (
  SELECT 
    *,
    
    -- Meeting quality threshold based on type
    CASE 
      WHEN MEETING_CATEGORY = 'External/Client' THEN 9.0
      WHEN MEETING_CATEGORY = 'Company-wide' THEN 8.5
      WHEN MEETING_CATEGORY = 'Presentation/Demo' THEN 8.0
      WHEN MEETING_CATEGORY = 'Learning/Development' THEN 7.5
      WHEN MEETING_CATEGORY = 'Strategic Planning' THEN 7.0
      ELSE 6.5
    END AS MEETING_QUALITY_THRESHOLD,
    
    -- Typical features used (estimated based on meeting type)
    CASE 
      WHEN MEETING_CATEGORY = 'Presentation/Demo' THEN 'Screen Share, Recording, Chat'
      WHEN MEETING_CATEGORY = 'Learning/Development' THEN 'Screen Share, Recording, Polls, Breakout Rooms'
      WHEN MEETING_CATEGORY = 'External/Client' THEN 'Screen Share, Recording, File Sharing'
      WHEN MEETING_CATEGORY = 'Company-wide' THEN 'Recording, Polls, Chat'
      WHEN MEETING_CATEGORY = 'Strategic Planning' THEN 'Screen Share, Whiteboard, Recording'
      WHEN MEETING_CATEGORY = 'Review/Feedback' THEN 'Screen Share, Chat, Recording'
      WHEN MEETING_CATEGORY = 'Social/Team Building' THEN 'Video, Chat, Breakout Rooms'
      ELSE 'Video, Audio, Chat'
    END AS TYPICAL_FEATURES_USED,
    
    -- Business purpose
    CASE 
      WHEN MEETING_CATEGORY = 'Operational' THEN 'Daily Operations and Status Updates'
      WHEN MEETING_CATEGORY = 'HR/Recruitment' THEN 'Talent Acquisition and HR Processes'
      WHEN MEETING_CATEGORY = 'Learning/Development' THEN 'Knowledge Transfer and Skill Development'
      WHEN MEETING_CATEGORY = 'Presentation/Demo' THEN 'Information Sharing and Product Demonstration'
      WHEN MEETING_CATEGORY = 'Review/Feedback' THEN 'Performance Review and Process Improvement'
      WHEN MEETING_CATEGORY = 'Strategic Planning' THEN 'Strategic Decision Making and Planning'
      WHEN MEETING_CATEGORY = 'Personal/1:1' THEN 'Individual Development and Feedback'
      WHEN MEETING_CATEGORY = 'Company-wide' THEN 'Organization-wide Communication'
      WHEN MEETING_CATEGORY = 'External/Client' THEN 'Client Relationship and Business Development'
      WHEN MEETING_CATEGORY = 'Social/Team Building' THEN 'Team Cohesion and Culture Building'
      ELSE 'General Business Communication'
    END AS BUSINESS_PURPOSE,
    
    -- Meeting complexity score
    CASE 
      WHEN MEETING_CATEGORY = 'Learning/Development' AND PARTICIPANT_SIZE_CATEGORY = 'Large (50+)' THEN 'High'
      WHEN MEETING_CATEGORY = 'External/Client' THEN 'High'
      WHEN MEETING_CATEGORY = 'Company-wide' THEN 'High'
      WHEN MEETING_CATEGORY = 'Strategic Planning' THEN 'Medium-High'
      WHEN MEETING_CATEGORY = 'Presentation/Demo' THEN 'Medium'
      ELSE 'Low-Medium'
    END AS MEETING_COMPLEXITY,
    
    -- Priority level
    CASE 
      WHEN MEETING_CATEGORY = 'External/Client' THEN 'Critical'
      WHEN MEETING_CATEGORY = 'Company-wide' THEN 'High'
      WHEN MEETING_CATEGORY = 'Strategic Planning' THEN 'High'
      WHEN MEETING_CATEGORY = 'HR/Recruitment' THEN 'Medium-High'
      WHEN MEETING_CATEGORY = 'Operational' AND IS_RECURRING_TYPE = TRUE THEN 'Medium'
      ELSE 'Standard'
    END AS PRIORITY_LEVEL
    
  FROM meeting_type_aggregated
),

-- =====================================================
-- FINAL DIMENSION STRUCTURE
-- =====================================================

final_dimension AS (
  SELECT 
    -- Surrogate key (auto-increment will be handled by Snowflake)
    ROW_NUMBER() OVER (ORDER BY MEETING_CATEGORY, MEETING_TYPE) AS MEETING_TYPE_ID,
    
    -- Meeting type identification
    MEETING_TYPE,
    MEETING_CATEGORY,
    DURATION_CATEGORY,
    PARTICIPANT_SIZE_CATEGORY,
    
    -- Time-based attributes
    TIME_OF_DAY_CATEGORY,
    DAY_NAME AS DAY_OF_WEEK,
    IS_WEEKEND_MEETING,
    IS_RECURRING_TYPE,
    
    -- Quality and business attributes
    MEETING_QUALITY_THRESHOLD,
    TYPICAL_FEATURES_USED,
    BUSINESS_PURPOSE,
    MEETING_COMPLEXITY,
    PRIORITY_LEVEL,
    
    -- Statistical attributes
    MEETING_COUNT AS SAMPLE_SIZE,
    ROUND(AVG_DURATION_MINUTES, 2) AS AVERAGE_DURATION_MINUTES,
    
    -- Standard metadata
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    COALESCE(SOURCE_SYSTEM, 'SILVER_LAYER') AS SOURCE_SYSTEM
    
  FROM meeting_type_enriched
)

-- =====================================================
-- FINAL OUTPUT WITH QUALITY VALIDATION
-- =====================================================

SELECT 
  MEETING_TYPE_ID,
  MEETING_TYPE,
  MEETING_CATEGORY,
  DURATION_CATEGORY,
  PARTICIPANT_SIZE_CATEGORY,
  TIME_OF_DAY_CATEGORY,
  DAY_OF_WEEK,
  IS_WEEKEND_MEETING,
  IS_RECURRING_TYPE,
  MEETING_QUALITY_THRESHOLD,
  TYPICAL_FEATURES_USED,
  BUSINESS_PURPOSE,
  LOAD_DATE,
  UPDATE_DATE,
  SOURCE_SYSTEM
  
FROM final_dimension

-- Data quality validation
WHERE MEETING_TYPE IS NOT NULL
  AND MEETING_CATEGORY IS NOT NULL
  AND DURATION_CATEGORY IS NOT NULL
  AND TIME_OF_DAY_CATEGORY IS NOT NULL
  AND MEETING_QUALITY_THRESHOLD BETWEEN 0 AND 10
  AND SAMPLE_SIZE > 0

ORDER BY MEETING_CATEGORY, MEETING_TYPE

-- =====================================================
-- MODEL DOCUMENTATION
-- =====================================================

/*
MODEL DESCRIPTION:
This model creates the meeting type dimension table containing comprehensive 
meeting types and characteristics derived from meeting patterns and topics.

KEY FEATURES:
1. Intelligent meeting type classification based on topic analysis
2. Comprehensive meeting categorization for business analysis
3. Time-based pattern analysis (time of day, day of week)
4. Duration and participant size categorization
5. Business purpose and complexity assessment
6. Quality threshold assignment by meeting type
7. Typical feature usage patterns
8. Recurring meeting type identification

MEETING TYPES:
- Daily Standup: Daily operational meetings
- Interview: HR and recruitment meetings
- Training/Workshop: Learning and development sessions
- Demo/Presentation: Product demos and presentations
- Review/Retrospective: Performance and process reviews
- Planning/Strategy: Strategic planning sessions
- One-on-One: Personal development meetings
- All Hands/Company: Organization-wide meetings
- Client/External: External stakeholder meetings
- Team Sync: Team coordination meetings
- Webinar/Seminar: Educational broadcasts
- Social/Informal: Team building activities
- Standard Meeting: General business meetings

MEETING CATEGORIES:
- Operational: Daily operations and status updates
- HR/Recruitment: Talent acquisition processes
- Learning/Development: Knowledge transfer and training
- Presentation/Demo: Information sharing and demos
- Review/Feedback: Performance and process improvement
- Strategic Planning: Strategic decision making
- Personal/1:1: Individual development
- Company-wide: Organization communication
- External/Client: Client relationship management
- Social/Team Building: Culture and team cohesion
- General Business: Standard business communication

DURATION CATEGORIES:
- Brief: ≤ 15 minutes
- Short: 16-30 minutes
- Standard: 31-60 minutes
- Extended: 61-120 minutes
- Long: 121-240 minutes
- Marathon: > 240 minutes

TIME OF DAY CATEGORIES:
- Early Morning: 5-8 AM
- Morning: 9-11 AM
- Lunch Time: 12-1 PM
- Afternoon: 2-5 PM
- Evening: 6-8 PM
- Late Evening: 9-11 PM
- Night: 12-4 AM

PARTICIPANT SIZE CATEGORIES:
- Small (2-3): One-on-one meetings
- Small-Medium (3-8): Small team meetings
- Medium (4-10): Team meetings
- Medium-Large (10-30): Department meetings
- Large (50+): Company-wide meetings

QUALITY THRESHOLDS:
- External/Client: 9.0 (highest quality required)
- Company-wide: 8.5
- Presentation/Demo: 8.0
- Learning/Development: 7.5
- Strategic Planning: 7.0
- Others: 6.5

DATA QUALITY:
- Validates meeting types and categories are not null
- Ensures quality thresholds are within valid range
- Maintains statistical sample size requirements
- Handles null meeting topics gracefully

PERFORMANCE OPTIMIZATIONS:
- Clustered by MEETING_TYPE_ID and TIME_OF_DAY_CATEGORY
- Pre-calculated meeting characteristics
- Efficient pattern matching logic
- Optimized for fact table joins

USAGE:
- Join to fact tables using MEETING_TYPE_ID (surrogate key)
- Filter by MEETING_CATEGORY for category-specific analysis
- Use TIME_OF_DAY_CATEGORY for temporal analysis
- Analyze meeting patterns by DURATION_CATEGORY
- Quality analysis using MEETING_QUALITY_THRESHOLD

MONITORING:
- Monitor for new meeting patterns and types
- Validate meeting type classification accuracy
- Check quality threshold appropriateness
- Ensure proper business purpose alignment
*/

-- =====================================================
-- END OF MEETING TYPE DIMENSION MODEL
-- =====================================================