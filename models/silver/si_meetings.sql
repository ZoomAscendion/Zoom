{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('si_pipeline_audit') }} (
            execution_id, pipeline_name, start_time, status, 
            source_tables_processed, executed_by, execution_environment,
            load_date, update_date, source_system
        )
        VALUES (
            '{{ invocation_id }}_si_meetings', 
            'si_meetings', 
            CURRENT_TIMESTAMP(), 
            'STARTED',
            'BZ_MEETINGS',
            '{{ var(\"audit_user\") }}',
            'PRODUCTION',
            CURRENT_DATE(),
            CURRENT_DATE(),
            'DBT_SILVER_PIPELINE'
        )
    ",
    post_hook="
        UPDATE {{ ref('si_pipeline_audit') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
            target_tables_updated = 'SI_MEETINGS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            records_inserted = (SELECT COUNT(*) FROM {{ this }}),
            records_updated = 0,
            records_rejected = 0,
            update_date = CURRENT_DATE()
        WHERE execution_id = '{{ invocation_id }}_si_meetings'
    "
) }}

-- Silver layer transformation for Meetings
WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'bz_meetings') }}
),

bronze_users AS (
    SELECT user_id, user_name
    FROM {{ source('bronze', 'bz_users') }}
),

participant_counts AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ source('bronze', 'bz_participants') }}
    GROUP BY meeting_id
),

-- Data Quality Checks and Cleansing
cleansed_meetings AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        TRIM(m.meeting_topic) AS meeting_topic_clean,
        m.start_time,
        m.end_time,
        m.duration_minutes,
        m.load_timestamp,
        m.update_timestamp,
        m.source_system,
        
        -- Data Quality Validations
        CASE 
            WHEN m.meeting_id IS NULL THEN 0
            WHEN m.host_id IS NULL THEN 0
            WHEN m.start_time IS NULL THEN 0
            WHEN m.end_time IS NOT NULL AND m.end_time < m.start_time THEN 0
            WHEN m.duration_minutes IS NOT NULL AND m.duration_minutes < 0 THEN 0
            ELSE 1
        END AS meeting_valid,
        
        -- Corrected end_time if invalid
        CASE 
            WHEN m.end_time IS NULL AND m.duration_minutes IS NOT NULL 
            THEN DATEADD('minute', m.duration_minutes, m.start_time)
            WHEN m.end_time < m.start_time AND m.duration_minutes IS NOT NULL
            THEN DATEADD('minute', m.duration_minutes, m.start_time)
            ELSE m.end_time
        END AS end_time_corrected,
        
        -- Corrected duration
        CASE 
            WHEN m.duration_minutes IS NULL OR m.duration_minutes < 0
            THEN DATEDIFF('minute', m.start_time, 
                CASE 
                    WHEN m.end_time IS NULL THEN DATEADD('hour', 1, m.start_time)
                    WHEN m.end_time < m.start_time THEN DATEADD('hour', 1, m.start_time)
                    ELSE m.end_time
                END)
            ELSE m.duration_minutes
        END AS duration_minutes_corrected
        
    FROM bronze_meetings m
),

-- Remove duplicates
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS rn
    FROM cleansed_meetings
    WHERE meeting_valid = 1
),

-- Final transformation with enrichment
final_meetings AS (
    SELECT 
        m.meeting_id,
        m.host_id,
        COALESCE(m.meeting_topic_clean, 'Untitled Meeting') AS meeting_topic,
        
        -- Derive meeting type from duration and other attributes
        CASE 
            WHEN m.duration_minutes_corrected <= 30 THEN 'Instant'
            WHEN m.duration_minutes_corrected <= 60 THEN 'Scheduled'
            WHEN m.duration_minutes_corrected > 240 THEN 'Webinar'
            ELSE 'Personal'
        END AS meeting_type,
        
        m.start_time,
        m.end_time_corrected AS end_time,
        m.duration_minutes_corrected AS duration_minutes,
        
        -- Join with users to get host name
        COALESCE(u.user_name, 'Unknown Host') AS host_name,
        
        -- Derive meeting status
        CASE 
            WHEN m.end_time_corrected IS NULL THEN 'Scheduled'
            WHEN m.end_time_corrected < CURRENT_TIMESTAMP() THEN 'Completed'
            WHEN m.start_time <= CURRENT_TIMESTAMP() AND m.end_time_corrected > CURRENT_TIMESTAMP() THEN 'In Progress'
            ELSE 'Scheduled'
        END AS meeting_status,
        
        -- Derive recording status (simplified logic)
        CASE 
            WHEN m.duration_minutes_corrected > 60 THEN 'Yes'
            ELSE 'No'
        END AS recording_status,
        
        COALESCE(pc.participant_count, 0) AS participant_count,
        
        -- Metadata columns
        m.load_timestamp,
        m.update_timestamp,
        m.source_system,
        
        -- Data quality score
        CASE 
            WHEN m.meeting_topic_clean IS NOT NULL 
                AND m.start_time IS NOT NULL 
                AND m.end_time_corrected IS NOT NULL 
                AND m.duration_minutes_corrected > 0
            THEN 1.00
            ELSE 0.75
        END AS data_quality_score,
        
        DATE(m.load_timestamp) AS load_date,
        DATE(m.update_timestamp) AS update_date
        
    FROM deduped_meetings m
    LEFT JOIN bronze_users u ON m.host_id = u.user_id
    LEFT JOIN participant_counts pc ON m.meeting_id = pc.meeting_id
    WHERE m.rn = 1
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
FROM final_meetings
