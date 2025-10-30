{{
    config(
        materialized='incremental',
        unique_key='meeting_id',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Meetings Transformation
-- Source: Bronze.BZ_MEETINGS
-- Target: Silver.SI_MEETINGS

WITH bronze_meetings AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE MEETING_ID IS NOT NULL
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Join with Users for Host Information
meeting_with_host AS (
    SELECT 
        m.*,
        u.user_name AS host_name
    FROM bronze_meetings m
    LEFT JOIN {{ ref('si_users') }} u ON m.HOST_ID = u.user_id
),

-- Data Quality and Transformation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN MEETING_ID IS NULL THEN 0.0
            WHEN START_TIME IS NULL OR END_TIME IS NULL THEN 0.2
            WHEN END_TIME < START_TIME THEN 0.3
            WHEN DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440 THEN 0.4
            WHEN HOST_ID IS NULL THEN 0.6
            WHEN ABS(DATEDIFF('minute', START_TIME, END_TIME) - DURATION_MINUTES) > 1 THEN 0.7
            ELSE 1.0
        END AS data_quality_score,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM meeting_with_host
),

-- Participant Count Calculation
participant_counts AS (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT USER_ID) AS participant_count
    FROM {{ source('bronze', 'bz_participants') }}
    GROUP BY MEETING_ID
),

-- Final Transformation
transformed_meetings AS (
    SELECT 
        TRIM(m.MEETING_ID) AS meeting_id,
        TRIM(m.HOST_ID) AS host_id,
        TRIM(COALESCE(m.MEETING_TOPIC, 'Untitled Meeting')) AS meeting_topic,
        CASE 
            WHEN m.MEETING_TOPIC ILIKE '%webinar%' THEN 'Webinar'
            WHEN m.MEETING_TOPIC ILIKE '%instant%' THEN 'Instant'
            WHEN m.MEETING_TOPIC ILIKE '%personal%' THEN 'Personal'
            ELSE 'Scheduled'
        END AS meeting_type,
        m.START_TIME AS start_time,
        m.END_TIME AS end_time,
        GREATEST(0, COALESCE(m.DURATION_MINUTES, DATEDIFF('minute', m.START_TIME, m.END_TIME))) AS duration_minutes,
        COALESCE(m.host_name, 'Unknown Host') AS host_name,
        CASE 
            WHEN m.END_TIME < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN m.START_TIME <= CURRENT_TIMESTAMP() AND m.END_TIME >= CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN m.START_TIME > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Unknown'
        END AS meeting_status,
        'No' AS recording_status,  -- Default value, can be enhanced with actual data
        COALESCE(p.participant_count, 0) AS participant_count,
        m.LOAD_TIMESTAMP AS load_timestamp,
        m.UPDATE_TIMESTAMP AS update_timestamp,
        m.SOURCE_SYSTEM AS source_system,
        m.data_quality_score,
        DATE(m.LOAD_TIMESTAMP) AS load_date,
        DATE(m.UPDATE_TIMESTAMP) AS update_date
    FROM data_quality_checks m
    LEFT JOIN participant_counts p ON m.MEETING_ID = p.MEETING_ID
    WHERE m.rn = 1  -- Remove duplicates
        AND m.data_quality_score > 0.0  -- Remove records with critical quality issues
        AND m.START_TIME IS NOT NULL
        AND m.END_TIME IS NOT NULL
        AND m.END_TIME >= m.START_TIME
)

SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    meeting_type,
    start_time,
    end_time,
    duration_minutes,
    host_name,
    meeting_status,
    recording_status,
    participant_count,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM transformed_meetings
