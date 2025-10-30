{{ config(
    materialized='incremental',
    unique_key='meeting_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for meetings with data quality checks and deduplication
WITH bronze_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY meeting_id ORDER BY update_timestamp DESC, load_timestamp DESC) as rn
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE meeting_id IS NOT NULL 
    AND TRIM(meeting_id) != ''
    AND start_time IS NOT NULL
    AND end_time IS NOT NULL
    AND end_time >= start_time
    AND duration_minutes >= 0
    AND duration_minutes <= 1440
    {% if is_incremental() %}
        AND (update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
             OR load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }}))
    {% endif %}
),

deduped_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_meetings
    WHERE rn = 1
),

validated_meetings AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        CASE 
            WHEN m.meeting_topic IS NOT NULL AND TRIM(m.meeting_topic) != ''
            THEN TRIM(m.meeting_topic)
            ELSE 'Untitled Meeting'
        END AS meeting_topic,
        CASE 
            WHEN m.meeting_topic LIKE '%webinar%' OR m.meeting_topic LIKE '%Webinar%' THEN 'Webinar'
            WHEN m.duration_minutes < 5 THEN 'Instant'
            WHEN m.meeting_topic LIKE '%personal%' OR m.meeting_topic LIKE '%Personal%' THEN 'Personal'
            ELSE 'Scheduled'
        END AS meeting_type,
        m.start_time,
        m.end_time,
        COALESCE(m.duration_minutes, DATEDIFF('minute', m.start_time, m.end_time)) AS duration_minutes,
        COALESCE(u.user_name, 'Unknown Host') AS host_name,
        CASE 
            WHEN m.end_time < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN m.start_time <= CURRENT_TIMESTAMP() AND m.end_time >= CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN m.start_time > CURRENT_TIMESTAMP() THEN 'Scheduled'
            ELSE 'Unknown'
        END AS meeting_status,
        'No' AS recording_status,
        0 AS participant_count,
        m.load_timestamp,
        m.update_timestamp,
        m.source_system
    FROM deduped_meetings m
    LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
),

final_meetings AS (
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
        -- Calculate data quality score with proper precision
        CAST(ROUND(
            (CASE WHEN meeting_id IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN host_id IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN meeting_topic != 'Untitled Meeting' THEN 0.2 ELSE 0 END +
             CASE WHEN start_time IS NOT NULL AND end_time IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN duration_minutes > 0 THEN 0.2 ELSE 0 END), 2
        ) AS NUMBER(3,2)) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_meetings
)

SELECT * FROM final_meetings
