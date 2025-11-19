{{ config(
    materialized='table',
    schema='gold',
    tags=['fact', 'meeting_activity'],
    unique_key='meeting_activity_id'
) }}

-- Meeting activity fact table for Gold layer
-- Contains comprehensive meeting metrics and analytics

WITH source_meetings AS (
    SELECT 
        m.MEETING_ID,
        m.HOST_ID,
        m.MEETING_TOPIC,
        m.START_TIME,
        m.END_TIME,
        m.DURATION_MINUTES,
        m.LOAD_TIMESTAMP,
        m.UPDATE_TIMESTAMP,
        m.SOURCE_SYSTEM,
        m.LOAD_DATE,
        m.UPDATE_DATE,
        m.DATA_QUALITY_SCORE,
        m.VALIDATION_STATUS
    FROM {{ source('silver', 'SI_MEETINGS') }} m
    WHERE m.VALIDATION_STATUS = 'VALID'
        AND m.DATA_QUALITY_SCORE >= 0.7
),

participant_metrics AS (
    SELECT 
        p.MEETING_ID,
        COUNT(DISTINCT p.USER_ID) AS participant_count,
        COUNT(DISTINCT p.PARTICIPANT_ID) AS unique_participants,
        SUM(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, p.JOIN_TIME + INTERVAL '60 minutes'))) AS total_participant_minutes,
        AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, p.JOIN_TIME + INTERVAL '60 minutes'))) AS average_participation_minutes,
        MAX(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, p.JOIN_TIME + INTERVAL '60 minutes'))) AS max_participation_minutes,
        
        -- Late joiners (joined more than 5 minutes after start)
        COUNT(CASE WHEN DATEDIFF('minute', 
            (SELECT MIN(JOIN_TIME) FROM {{ source('silver', 'SI_PARTICIPANTS') }} p2 
             WHERE p2.MEETING_ID = p.MEETING_ID AND p2.VALIDATION_STATUS = 'VALID'), 
            p.JOIN_TIME) > 5 THEN 1 END) AS late_joiners_count,
            
        -- Early leavers (left more than 5 minutes before meeting end)
        COUNT(CASE WHEN p.LEAVE_TIME IS NOT NULL AND 
            DATEDIFF('minute', p.LEAVE_TIME, 
                (SELECT MAX(COALESCE(LEAVE_TIME, JOIN_TIME + INTERVAL '60 minutes')) 
                 FROM {{ source('silver', 'SI_PARTICIPANTS') }} p3 
                 WHERE p3.MEETING_ID = p.MEETING_ID AND p3.VALIDATION_STATUS = 'VALID')) > 5 
            THEN 1 END) AS early_leavers_count
            
    FROM {{ source('silver', 'SI_PARTICIPANTS') }} p
    WHERE p.VALIDATION_STATUS = 'VALID'
        AND p.DATA_QUALITY_SCORE >= 0.7
    GROUP BY p.MEETING_ID
),

feature_usage_metrics AS (
    SELECT 
        fu.MEETING_ID,
        COUNT(DISTINCT fu.FEATURE_NAME) AS features_used_count,
        
        -- Specific feature usage durations (estimated)
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN fu.USAGE_COUNT * 10 ELSE 0 END) AS screen_share_duration_minutes,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%RECORD%' THEN fu.USAGE_COUNT * 30 ELSE 0 END) AS recording_duration_minutes,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%CHAT%' THEN fu.USAGE_COUNT ELSE 0 END) AS chat_messages_count,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%FILE%' THEN fu.USAGE_COUNT ELSE 0 END) AS file_shares_count,
        
        -- Advanced features
        MAX(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%BREAKOUT%' THEN 1 ELSE 0 END) AS breakout_rooms_used,
        SUM(CASE WHEN UPPER(fu.FEATURE_NAME) LIKE '%POLL%' THEN fu.USAGE_COUNT ELSE 0 END) AS polls_conducted
        
    FROM {{ source('silver', 'SI_FEATURE_USAGE') }} fu
    WHERE fu.VALIDATION_STATUS = 'VALID'
        AND fu.DATA_QUALITY_SCORE >= 0.7
    GROUP BY fu.MEETING_ID
),

meeting_activity_transformations AS (
    SELECT 
        -- Generate surrogate key for fact table
        {{ dbt_utils.generate_surrogate_key(['m.MEETING_ID']) }} AS meeting_activity_id,
        
        -- Dimension keys
        dd.date_id,
        dmt.meeting_type_id,
        du.user_dim_id AS host_user_dim_id,
        
        -- Original meeting ID
        m.MEETING_ID,
        
        -- Date and time fields
        DATE(m.START_TIME) AS meeting_date,
        m.START_TIME AS meeting_start_time,
        m.END_TIME AS meeting_end_time,
        
        -- Duration metrics
        m.DURATION_MINUTES AS scheduled_duration_minutes,
        COALESCE(DATEDIFF('minute', m.START_TIME, m.END_TIME), m.DURATION_MINUTES) AS actual_duration_minutes,
        
        -- Participant metrics
        COALESCE(pm.participant_count, 0) AS participant_count,
        COALESCE(pm.unique_participants, 0) AS unique_participants,
        
        -- Host duration (assume host was present for full meeting)
        COALESCE(DATEDIFF('minute', m.START_TIME, m.END_TIME), m.DURATION_MINUTES) AS host_duration_minutes,
        
        -- Participation metrics
        COALESCE(pm.total_participant_minutes, 0) AS total_participant_minutes,
        COALESCE(pm.average_participation_minutes, 0) AS average_participation_minutes,
        
        -- Peak concurrent participants (estimated as total participants for simplicity)
        COALESCE(pm.participant_count, 0) AS peak_concurrent_participants,
        
        -- Attendance patterns
        COALESCE(pm.late_joiners_count, 0) AS late_joiners_count,
        COALESCE(pm.early_leavers_count, 0) AS early_leavers_count,
        
        -- Feature usage metrics
        COALESCE(fum.features_used_count, 0) AS features_used_count,
        COALESCE(fum.screen_share_duration_minutes, 0) AS screen_share_duration_minutes,
        COALESCE(fum.recording_duration_minutes, 0) AS recording_duration_minutes,
        COALESCE(fum.chat_messages_count, 0) AS chat_messages_count,
        COALESCE(fum.file_shares_count, 0) AS file_shares_count,
        COALESCE(fum.breakout_rooms_used, 0) AS breakout_rooms_used,
        COALESCE(fum.polls_conducted, 0) AS polls_conducted,
        
        -- Quality scores (calculated based on various factors)
        CASE 
            WHEN m.DATA_QUALITY_SCORE >= 0.9 AND COALESCE(pm.participant_count, 0) > 1 AND m.DURATION_MINUTES >= 15 THEN 95
            WHEN m.DATA_QUALITY_SCORE >= 0.8 AND COALESCE(pm.participant_count, 0) > 0 AND m.DURATION_MINUTES >= 10 THEN 85
            WHEN m.DATA_QUALITY_SCORE >= 0.7 AND m.DURATION_MINUTES >= 5 THEN 75
            ELSE 65
        END AS meeting_quality_score,
        
        -- Audio quality score (estimated based on duration and participants)
        CASE 
            WHEN m.DURATION_MINUTES >= 30 AND COALESCE(pm.participant_count, 0) <= 10 THEN 95
            WHEN m.DURATION_MINUTES >= 15 AND COALESCE(pm.participant_count, 0) <= 20 THEN 85
            WHEN m.DURATION_MINUTES >= 5 THEN 75
            ELSE 65
        END AS audio_quality_score,
        
        -- Video quality score (similar logic)
        CASE 
            WHEN m.DURATION_MINUTES >= 30 AND COALESCE(pm.participant_count, 0) <= 8 THEN 95
            WHEN m.DURATION_MINUTES >= 15 AND COALESCE(pm.participant_count, 0) <= 15 THEN 85
            WHEN m.DURATION_MINUTES >= 5 THEN 75
            ELSE 65
        END AS video_quality_score,
        
        -- Connection issues count (estimated based on data quality)
        CASE 
            WHEN m.DATA_QUALITY_SCORE < 0.8 THEN 3
            WHEN m.DATA_QUALITY_SCORE < 0.9 THEN 1
            ELSE 0
        END AS connection_issues_count,
        
        -- Meeting satisfaction score (composite score)
        CASE 
            WHEN m.DURATION_MINUTES >= 30 AND COALESCE(pm.participant_count, 0) > 2 AND COALESCE(fum.features_used_count, 0) > 2 THEN 5
            WHEN m.DURATION_MINUTES >= 15 AND COALESCE(pm.participant_count, 0) > 1 AND COALESCE(fum.features_used_count, 0) > 1 THEN 4
            WHEN m.DURATION_MINUTES >= 10 AND COALESCE(pm.participant_count, 0) > 0 THEN 3
            WHEN m.DURATION_MINUTES >= 5 THEN 2
            ELSE 1
        END AS meeting_satisfaction_score,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        m.SOURCE_SYSTEM AS source_system
        
    FROM source_meetings m
    LEFT JOIN participant_metrics pm ON m.MEETING_ID = pm.MEETING_ID
    LEFT JOIN feature_usage_metrics fum ON m.MEETING_ID = fum.MEETING_ID
    
    -- Join with dimension tables
    LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(m.START_TIME) = dd.date_value
    LEFT JOIN {{ ref('go_dim_meeting_type') }} dmt ON (
        -- Join based on meeting characteristics
        CASE 
            WHEN UPPER(m.MEETING_TOPIC) LIKE '%STANDUP%' OR UPPER(m.MEETING_TOPIC) LIKE '%DAILY%' THEN 'Daily Standup'
            WHEN UPPER(m.MEETING_TOPIC) LIKE '%TRAINING%' OR UPPER(m.MEETING_TOPIC) LIKE '%WORKSHOP%' THEN 'Training'
            WHEN UPPER(m.MEETING_TOPIC) LIKE '%INTERVIEW%' OR UPPER(m.MEETING_TOPIC) LIKE '%HIRING%' THEN 'Interview'
            WHEN UPPER(m.MEETING_TOPIC) LIKE '%PRESENTATION%' OR UPPER(m.MEETING_TOPIC) LIKE '%DEMO%' THEN 'Presentation'
            WHEN UPPER(m.MEETING_TOPIC) LIKE '%REVIEW%' OR UPPER(m.MEETING_TOPIC) LIKE '%RETROSPECTIVE%' THEN 'Review'
            WHEN UPPER(m.MEETING_TOPIC) LIKE '%PLANNING%' OR UPPER(m.MEETING_TOPIC) LIKE '%STRATEGY%' THEN 'Planning'
            WHEN UPPER(m.MEETING_TOPIC) LIKE '%WEBINAR%' OR UPPER(m.MEETING_TOPIC) LIKE '%SEMINAR%' THEN 'Webinar'
            WHEN UPPER(m.MEETING_TOPIC) LIKE '%SOCIAL%' OR UPPER(m.MEETING_TOPIC) LIKE '%COFFEE%' THEN 'Social'
            ELSE 'General Meeting'
        END = dmt.meeting_type
    )
    LEFT JOIN {{ ref('go_dim_user') }} du ON m.HOST_ID = du.user_id AND du.is_current_record = TRUE
)

SELECT 
    meeting_activity_id,
    date_id,
    meeting_type_id,
    host_user_dim_id,
    meeting_id,
    meeting_date,
    meeting_start_time,
    meeting_end_time,
    scheduled_duration_minutes,
    actual_duration_minutes,
    participant_count,
    unique_participants,
    host_duration_minutes,
    total_participant_minutes,
    average_participation_minutes,
    peak_concurrent_participants,
    late_joiners_count,
    early_leavers_count,
    features_used_count,
    screen_share_duration_minutes,
    recording_duration_minutes,
    chat_messages_count,
    file_shares_count,
    breakout_rooms_used,
    polls_conducted,
    meeting_quality_score,
    audio_quality_score,
    video_quality_score,
    connection_issues_count,
    meeting_satisfaction_score,
    load_date,
    update_date,
    source_system
FROM meeting_activity_transformations
ORDER BY meeting_date DESC, meeting_start_time DESC