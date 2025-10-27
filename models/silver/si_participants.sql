{{
  config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge',
    pre_hook="
      INSERT INTO {{ ref('audit_log') }} (
        audit_id, pipeline_name, start_time, status, execution_id, 
        execution_start_time, source_table, target_table, execution_status, 
        processed_by, load_timestamp
      )
      SELECT
        MD5('si_participants_' || CURRENT_TIMESTAMP()::VARCHAR),
        'si_participants_transformation',
        CURRENT_TIMESTAMP(),
        'RUNNING',
        MD5('exec_' || CURRENT_TIMESTAMP()::VARCHAR),
        CURRENT_TIMESTAMP(),
        'bz_participants',
        'si_participants',
        'STARTED',
        'DBT_SILVER_PIPELINE',
        CURRENT_TIMESTAMP()
    ",
    post_hook="
      INSERT INTO {{ ref('audit_log') }} (
        audit_id, pipeline_name, end_time, status, execution_id, 
        execution_end_time, source_table, target_table, execution_status, 
        processed_by, load_timestamp, records_processed
      )
      SELECT
        MD5('si_participants_complete_' || CURRENT_TIMESTAMP()::VARCHAR),
        'si_participants_transformation',
        CURRENT_TIMESTAMP(),
        'SUCCESS',
        MD5('exec_complete_' || CURRENT_TIMESTAMP()::VARCHAR),
        CURRENT_TIMESTAMP(),
        'bz_participants',
        'si_participants',
        'COMPLETED',
        'DBT_SILVER_PIPELINE',
        CURRENT_TIMESTAMP(),
        (SELECT COUNT(*) FROM {{ this }})
    "
  )
}}

-- Silver Participants Table Transformation
-- Transforms bronze participant data with attendance calculations and engagement metrics

WITH bronze_participants AS (
    SELECT 
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE meeting_id IS NOT NULL 
      AND user_id IS NOT NULL
      AND join_time IS NOT NULL
      AND (leave_time IS NULL OR leave_time >= join_time)
),

deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id, user_id, join_time 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM bronze_participants
),

meeting_durations AS (
    SELECT 
        meeting_id,
        duration_minutes
    FROM {{ ref('si_meetings') }}
),

transformed_participants AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['meeting_id', 'user_id', 'join_time']) }} AS participant_id,
        
        -- Direct Mappings
        p.meeting_id,
        p.user_id,
        p.join_time,
        p.leave_time,
        
        -- Calculated Attendance Metrics
        COALESCE(DATEDIFF(minute, p.join_time, p.leave_time), 0) AS attendance_duration_minutes,
        
        CASE 
            WHEN m.duration_minutes > 0 AND p.leave_time IS NOT NULL 
            THEN ROUND((DATEDIFF(minute, p.join_time, p.leave_time) * 100.0) / m.duration_minutes, 2)
            ELSE 0.00
        END AS attendance_percentage,
        
        -- Behavioral Flags
        FALSE AS late_join_flag,  -- Simplified for now
        FALSE AS early_leave_flag,  -- Simplified for now
        
        -- Engagement Score Calculation
        CASE 
            WHEN m.duration_minutes > 0 AND p.leave_time IS NOT NULL 
            THEN LEAST(1.00, ROUND((DATEDIFF(minute, p.join_time, p.leave_time) * 1.0) / m.duration_minutes, 2))
            ELSE 0.00
        END AS engagement_score,
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        p.source_system,
        p.load_timestamp,
        p.update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN p.meeting_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN p.user_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN p.join_time IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN p.leave_time IS NULL OR p.leave_time >= p.join_time THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_participants p
    LEFT JOIN meeting_durations m ON p.meeting_id = m.meeting_id
    WHERE p.row_num = 1
)

SELECT * FROM transformed_participants

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
