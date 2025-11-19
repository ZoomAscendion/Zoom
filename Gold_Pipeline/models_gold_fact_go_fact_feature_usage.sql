{{ config(
    materialized='table',
    schema='gold',
    tags=['fact', 'feature_usage'],
    unique_key='feature_usage_id'
) }}

-- Feature usage fact table for Gold layer
-- Contains detailed feature usage metrics and analytics

WITH source_feature_usage AS (
    SELECT 
        fu.USAGE_ID,
        fu.MEETING_ID,
        fu.FEATURE_NAME,
        fu.USAGE_COUNT,
        fu.USAGE_DATE,
        fu.LOAD_TIMESTAMP,
        fu.UPDATE_TIMESTAMP,
        fu.SOURCE_SYSTEM,
        fu.LOAD_DATE,
        fu.UPDATE_DATE,
        fu.DATA_QUALITY_SCORE,
        fu.VALIDATION_STATUS
    FROM {{ source('silver', 'SI_FEATURE_USAGE') }} fu
    WHERE fu.VALIDATION_STATUS = 'VALID'
        AND fu.DATA_QUALITY_SCORE >= 0.7
),

meeting_context AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        m.START_TIME,
        m.END_TIME,
        m.DURATION_MINUTES
    FROM {{ source('silver', 'SI_MEETINGS') }} m
    WHERE m.VALIDATION_STATUS = 'VALID'
        AND m.DATA_QUALITY_SCORE >= 0.7
),

participant_context AS (
    SELECT 
        p.MEETING_ID,
        COUNT(DISTINCT p.USER_ID) AS participant_count,
        AVG(DATEDIFF('minute', p.JOIN_TIME, p.LEAVE_TIME)) AS avg_participation_minutes
    FROM {{ source('silver', 'SI_PARTICIPANTS') }} p
    WHERE p.VALIDATION_STATUS = 'VALID'
        AND p.DATA_QUALITY_SCORE >= 0.7
    GROUP BY p.MEETING_ID
),

feature_usage_transformations AS (
    SELECT 
        -- Generate surrogate key for fact table
        {{ dbt_utils.generate_surrogate_key(['fu.USAGE_ID', 'fu.MEETING_ID', 'fu.FEATURE_NAME']) }} AS feature_usage_id,
        
        -- Dimension keys
        dd.date_id,
        df.feature_id,
        du.user_dim_id,
        
        -- Original IDs
        fu.MEETING_ID,
        
        -- Date and time fields
        fu.USAGE_DATE,
        COALESCE(m.START_TIME, fu.USAGE_DATE::TIMESTAMP) AS usage_timestamp,
        
        -- Feature information
        fu.FEATURE_NAME,
        
        -- Usage metrics
        fu.USAGE_COUNT,
        
        -- Calculated usage duration (estimated based on meeting duration and usage count)
        CASE 
            WHEN fu.USAGE_COUNT > 0 AND m.DURATION_MINUTES > 0 THEN 
                LEAST(m.DURATION_MINUTES, fu.USAGE_COUNT * 5)  -- Assume 5 minutes per usage on average
            ELSE 0
        END AS usage_duration_minutes,
        
        -- Session duration from meeting
        COALESCE(m.DURATION_MINUTES, 0) AS session_duration_minutes,
        
        -- Feature adoption score (0-100 based on usage frequency)
        CASE 
            WHEN fu.USAGE_COUNT >= 10 THEN 100
            WHEN fu.USAGE_COUNT >= 5 THEN 75
            WHEN fu.USAGE_COUNT >= 2 THEN 50
            WHEN fu.USAGE_COUNT >= 1 THEN 25
            ELSE 0
        END AS feature_adoption_score,
        
        -- User experience rating (estimated based on usage patterns)
        CASE 
            WHEN fu.USAGE_COUNT > 5 AND m.DURATION_MINUTES > 30 THEN 5  -- Excellent
            WHEN fu.USAGE_COUNT > 2 AND m.DURATION_MINUTES > 15 THEN 4  -- Good
            WHEN fu.USAGE_COUNT > 0 AND m.DURATION_MINUTES > 5 THEN 3   -- Average
            WHEN fu.USAGE_COUNT > 0 THEN 2                              -- Below Average
            ELSE 1                                                       -- Poor
        END AS user_experience_rating,
        
        -- Feature performance score (based on usage success)
        CASE 
            WHEN fu.DATA_QUALITY_SCORE >= 0.9 THEN 95
            WHEN fu.DATA_QUALITY_SCORE >= 0.8 THEN 85
            WHEN fu.DATA_QUALITY_SCORE >= 0.7 THEN 75
            ELSE 65
        END AS feature_performance_score,
        
        -- Concurrent features count (estimated)
        CASE 
            WHEN m.DURATION_MINUTES > 60 THEN 5
            WHEN m.DURATION_MINUTES > 30 THEN 3
            WHEN m.DURATION_MINUTES > 15 THEN 2
            ELSE 1
        END AS concurrent_features_count,
        
        -- Usage context
        CASE 
            WHEN pc.participant_count > 10 THEN 'Large Meeting'
            WHEN pc.participant_count > 5 THEN 'Medium Meeting'
            WHEN pc.participant_count > 1 THEN 'Small Meeting'
            ELSE 'Solo Session'
        END AS usage_context,
        
        -- Device type (estimated based on usage patterns)
        CASE 
            WHEN EXTRACT(HOUR FROM COALESCE(m.START_TIME, fu.USAGE_DATE::TIMESTAMP)) BETWEEN 9 AND 17 THEN 'Desktop'
            WHEN EXTRACT(HOUR FROM COALESCE(m.START_TIME, fu.USAGE_DATE::TIMESTAMP)) BETWEEN 18 AND 22 THEN 'Mobile'
            ELSE 'Tablet'
        END AS device_type,
        
        -- Platform version (simplified)
        'Zoom 5.0+' AS platform_version,
        
        -- Error count (estimated based on data quality)
        CASE 
            WHEN fu.DATA_QUALITY_SCORE < 0.8 THEN 2
            WHEN fu.DATA_QUALITY_SCORE < 0.9 THEN 1
            ELSE 0
        END AS error_count,
        
        -- Success rate percentage
        CASE 
            WHEN fu.DATA_QUALITY_SCORE >= 0.9 THEN 98.5
            WHEN fu.DATA_QUALITY_SCORE >= 0.8 THEN 95.0
            WHEN fu.DATA_QUALITY_SCORE >= 0.7 THEN 90.0
            ELSE 85.0
        END AS success_rate,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        fu.SOURCE_SYSTEM AS source_system
        
    FROM source_feature_usage fu
    LEFT JOIN meeting_context m ON fu.MEETING_ID = m.MEETING_ID
    LEFT JOIN participant_context pc ON fu.MEETING_ID = pc.MEETING_ID
    
    -- Join with dimension tables
    LEFT JOIN {{ ref('go_dim_date') }} dd ON fu.USAGE_DATE = dd.date_value
    LEFT JOIN {{ ref('go_dim_feature') }} df ON fu.FEATURE_NAME = df.feature_name
    LEFT JOIN {{ ref('go_dim_user') }} du ON m.HOST_ID = du.user_id AND du.is_current_record = TRUE
)

SELECT 
    feature_usage_id,
    date_id,
    feature_id,
    user_dim_id,
    meeting_id,
    usage_date,
    usage_timestamp,
    feature_name,
    usage_count,
    usage_duration_minutes,
    session_duration_minutes,
    feature_adoption_score,
    user_experience_rating,
    feature_performance_score,
    concurrent_features_count,
    usage_context,
    device_type,
    platform_version,
    error_count,
    success_rate,
    load_date,
    update_date,
    source_system
FROM feature_usage_transformations
ORDER BY usage_date DESC, feature_name