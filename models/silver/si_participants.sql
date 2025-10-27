{{
  config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge'
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

transformed_participants AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['meeting_id', 'user_id', 'join_time']) }} AS participant_id,
        
        -- Direct Mappings
        meeting_id,
        user_id,
        join_time,
        leave_time,
        
        -- Calculated Attendance Metrics
        COALESCE(DATEDIFF(minute, join_time, leave_time), 0) AS attendance_duration_minutes,
        
        CASE 
            WHEN leave_time IS NOT NULL 
            THEN ROUND((DATEDIFF(minute, join_time, leave_time) * 100.0) / GREATEST(DATEDIFF(minute, join_time, leave_time), 1), 2)
            ELSE 0.00
        END AS attendance_percentage,
        
        -- Behavioral Flags (simplified)
        FALSE AS late_join_flag,
        FALSE AS early_leave_flag,
        
        -- Engagement Score Calculation
        CASE 
            WHEN leave_time IS NOT NULL 
            THEN LEAST(1.00, ROUND(DATEDIFF(minute, join_time, leave_time) / 60.0, 2))
            ELSE 0.00
        END AS engagement_score,
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system,
        load_timestamp,
        update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN meeting_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN user_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN join_time IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN leave_time IS NULL OR leave_time >= join_time THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_participants
    WHERE row_num = 1
)

SELECT * FROM transformed_participants

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
