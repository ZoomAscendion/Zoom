{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['fact', 'meeting_activity']
) }}

-- Meeting activity fact table
-- Comprehensive meeting analytics with participant and feature usage metrics

WITH source_meetings AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        m.meeting_topic,
        m.start_time,
        m.end_time,
        m.duration_minutes,
        m.load_timestamp,
        m.update_timestamp,
        m.source_system,
        m.load_date,
        m.update_date,
        m.data_quality_score,
        m.validation_status
    FROM {{ source('silver_layer', 'si_meetings') }} m
    WHERE m.validation_status = 'VALID'
      AND m.data_quality_score >= {{ var('data_quality_threshold') }}
),

participant_metrics AS (
    SELECT 
        p.meeting_id,
        COUNT(DISTINCT p.user_id) AS participant_count,
        COUNT(DISTINCT p.participant_id) AS unique_participants,
        SUM(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, CURRENT_TIMESTAMP()))) AS total_participant_minutes,
        AVG(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, CURRENT_TIMESTAMP()))) AS average_participation_minutes,
        MAX(DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, CURRENT_TIMESTAMP()))) AS max_participation_minutes,
        
        -- Peak concurrent participants (simplified estimation)
        GREATEST(COUNT(DISTINCT p.user_id), 1) AS peak_concurrent_participants,
        
        -- Late joiners (joined after 5 minutes)
        COUNT(CASE WHEN DATEDIFF('minute', 
            (SELECT MIN(p2.join_time) FROM {{ source('silver_layer', 'si_participants') }} p2 
             WHERE p2.meeting_id = p.meeting_id AND p2.validation_status = 'VALID'), 
            p.join_time) > 5 THEN 1 END) AS late_joiners_count,
        
        -- Early leavers (left before meeting end - estimated)
        COUNT(CASE WHEN p.leave_time IS NOT NULL 
            AND DATEDIFF('minute', p.leave_time, CURRENT_TIMESTAMP()) > 30 THEN 1 END) AS early_leavers_count
            
    FROM {{ source('silver_layer', 'si_participants') }} p
    WHERE p.validation_status = 'VALID'
    GROUP BY p.meeting_id
),

feature_usage_metrics AS (
    SELECT 
        fu.meeting_id,
        COUNT(DISTINCT fu.feature_name) AS features_used_count,
        
        -- Screen share duration (estimated)
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%SCREEN%SHARE%' 
            THEN fu.usage_count * 5 ELSE 0 END) AS screen_share_duration_minutes,
        
        -- Recording duration (estimated)
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%RECORD%' 
            THEN fu.usage_count * 10 ELSE 0 END) AS recording_duration_minutes,
        
        -- Chat messages count
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%CHAT%' 
            THEN fu.usage_count ELSE 0 END) AS chat_messages_count,
        
        -- File shares count
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%FILE%' OR UPPER(fu.feature_name) LIKE '%SHARE%' 
            THEN fu.usage_count ELSE 0 END) AS file_shares_count,
        
        -- Breakout rooms used
        MAX(CASE WHEN UPPER(fu.feature_name) LIKE '%BREAKOUT%' 
            THEN fu.usage_count ELSE 0 END) AS breakout_rooms_used,
        
        -- Polls conducted
        SUM(CASE WHEN UPPER(fu.feature_name) LIKE '%POLL%' 
            THEN fu.usage_count ELSE 0 END) AS polls_conducted
            
    FROM {{ source('silver_layer', 'si_feature_usage') }} fu
    WHERE fu.validation_status = 'VALID'
    GROUP BY fu.meeting_id
),

meeting_activity_enriched AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        m.meeting_topic,
        m.start_time,
        m.end_time,
        m.duration_minutes,
        
        -- Dimension keys
        dd.date_id,
        dmt.meeting_type_id,
        du.user_dim_id AS host_user_dim_id,
        
        -- Date and time fields
        DATE(m.start_time) AS meeting_date,
        m.start_time AS meeting_start_time,
        m.end_time AS meeting_end_time,
        
        -- Duration metrics
        m.duration_minutes AS scheduled_duration_minutes,
        COALESCE(DATEDIFF('minute', m.start_time, m.end_time), m.duration_minutes) AS actual_duration_minutes,
        
        -- Participant metrics
        COALESCE(pm.participant_count, 1) AS participant_count,
        COALESCE(pm.unique_participants, 1) AS unique_participants,
        COALESCE(pm.total_participant_minutes, m.duration_minutes) AS total_participant_minutes,
        COALESCE(pm.average_participation_minutes, m.duration_minutes) AS average_participation_minutes,
        COALESCE(pm.peak_concurrent_participants, 1) AS peak_concurrent_participants,
        COALESCE(pm.late_joiners_count, 0) AS late_joiners_count,
        COALESCE(pm.early_leavers_count, 0) AS early_leavers_count,
        
        -- Host duration (assuming host stays for full meeting)
        m.duration_minutes AS host_duration_minutes,
        
        -- Feature usage metrics
        COALESCE(fm.features_used_count, 0) AS features_used_count,
        COALESCE(fm.screen_share_duration_minutes, 0) AS screen_share_duration_minutes,
        COALESCE(fm.recording_duration_minutes, 0) AS recording_duration_minutes,
        COALESCE(fm.chat_messages_count, 0) AS chat_messages_count,
        COALESCE(fm.file_shares_count, 0) AS file_shares_count,
        COALESCE(fm.breakout_rooms_used, 0) AS breakout_rooms_used,
        COALESCE(fm.polls_conducted, 0) AS polls_conducted,
        
        -- Quality metrics (calculated)
        CASE 
            WHEN m.duration_minutes >= 30 AND COALESCE(pm.participant_count, 1) >= 3 
                 AND COALESCE(fm.features_used_count, 0) >= 2 THEN 95
            WHEN m.duration_minutes >= 15 AND COALESCE(pm.participant_count, 1) >= 2 THEN 85
            WHEN m.duration_minutes >= 5 THEN 75
            ELSE 60
        END AS meeting_quality_score,
        
        -- Audio quality score (estimated)
        CASE 
            WHEN COALESCE(pm.participant_count, 1) <= 5 THEN 95
            WHEN COALESCE(pm.participant_count, 1) <= 15 THEN 90
            WHEN COALESCE(pm.participant_count, 1) <= 50 THEN 85
            ELSE 80
        END AS audio_quality_score,
        
        -- Video quality score (estimated)
        CASE 
            WHEN COALESCE(pm.participant_count, 1) <= 5 THEN 90
            WHEN COALESCE(pm.participant_count, 1) <= 15 THEN 85
            WHEN COALESCE(pm.participant_count, 1) <= 50 THEN 80
            ELSE 75
        END AS video_quality_score,
        
        -- Connection issues count (estimated)
        CASE 
            WHEN COALESCE(pm.early_leavers_count, 0) > 0 THEN pm.early_leavers_count
            WHEN m.duration_minutes < 5 THEN 1
            ELSE 0
        END AS connection_issues_count,
        
        -- Meeting satisfaction score (estimated)
        CASE 
            WHEN m.duration_minutes >= 30 AND COALESCE(fm.features_used_count, 0) >= 3 THEN 5
            WHEN m.duration_minutes >= 15 AND COALESCE(fm.features_used_count, 0) >= 2 THEN 4
            WHEN m.duration_minutes >= 5 THEN 3
            ELSE 2
        END AS meeting_satisfaction_score,
        
        -- Audit fields
        m.load_date,
        m.update_date,
        m.source_system
        
    FROM source_meetings m
    LEFT JOIN participant_metrics pm ON m.meeting_id = pm.meeting_id
    LEFT JOIN feature_usage_metrics fm ON m.meeting_id = fm.meeting_id
    LEFT JOIN {{ ref('go_dim_date') }} dd ON DATE(m.start_time) = dd.date_value
    LEFT JOIN {{ ref('go_dim_meeting_type') }} dmt ON (
        CASE 
            WHEN UPPER(m.meeting_topic) LIKE '%STANDUP%' OR UPPER(m.meeting_topic) LIKE '%DAILY%' THEN 'Daily Standup'
            WHEN UPPER(m.meeting_topic) LIKE '%TRAINING%' OR UPPER(m.meeting_topic) LIKE '%WORKSHOP%' THEN 'Training'
            WHEN UPPER(m.meeting_topic) LIKE '%INTERVIEW%' THEN 'Interview'
            WHEN UPPER(m.meeting_topic) LIKE '%DEMO%' OR UPPER(m.meeting_topic) LIKE '%PRESENTATION%' THEN 'Presentation'
            WHEN UPPER(m.meeting_topic) LIKE '%REVIEW%' THEN 'Review'
            WHEN UPPER(m.meeting_topic) LIKE '%PLANNING%' THEN 'Planning'
            WHEN UPPER(m.meeting_topic) LIKE '%SOCIAL%' THEN 'Social'
            ELSE 'General Meeting'
        END = dmt.meeting_type
    )
    LEFT JOIN {{ ref('go_dim_user') }} du ON m.host_id = du.user_id AND du.is_current_record = TRUE
)

SELECT 
    MD5(CONCAT(meeting_id, '_', meeting_start_time::STRING)) AS meeting_activity_id,
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
FROM meeting_activity_enriched
WHERE date_id IS NOT NULL
ORDER BY meeting_date DESC, meeting_start_time DESC