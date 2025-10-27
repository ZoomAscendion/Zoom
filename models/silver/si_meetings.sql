{{
  config(
    materialized='incremental',
    unique_key='meeting_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge',
    pre_hook="
      INSERT INTO {{ ref('audit_log') }} (
        audit_id, pipeline_name, start_time, status, execution_id, 
        execution_start_time, source_table, target_table, execution_status, 
        processed_by, load_timestamp
      )
      SELECT
        MD5('si_meetings_' || CURRENT_TIMESTAMP()::VARCHAR),
        'si_meetings_transformation',
        CURRENT_TIMESTAMP(),
        'RUNNING',
        MD5('exec_' || CURRENT_TIMESTAMP()::VARCHAR),
        CURRENT_TIMESTAMP(),
        'bz_meetings',
        'si_meetings',
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
        MD5('si_meetings_complete_' || CURRENT_TIMESTAMP()::VARCHAR),
        'si_meetings_transformation',
        CURRENT_TIMESTAMP(),
        'SUCCESS',
        MD5('exec_complete_' || CURRENT_TIMESTAMP()::VARCHAR),
        CURRENT_TIMESTAMP(),
        'bz_meetings',
        'si_meetings',
        'COMPLETED',
        'DBT_SILVER_PIPELINE',
        CURRENT_TIMESTAMP(),
        (SELECT COUNT(*) FROM {{ this }})
    "
  )
}}

-- Silver Meetings Table Transformation
-- Transforms bronze meeting data with duration validation and derived attributes

WITH bronze_meetings AS (
    SELECT 
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_meetings') }}
    WHERE host_id IS NOT NULL 
      AND start_time IS NOT NULL
      AND meeting_topic IS NOT NULL
      AND duration_minutes >= 0 
      AND duration_minutes <= 1440  -- Max 24 hours
      AND (end_time IS NULL OR end_time >= start_time)
),

deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY host_id, start_time, meeting_topic 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM bronze_meetings
),

transformed_meetings AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['host_id', 'start_time', 'meeting_topic']) }} AS meeting_id,
        
        -- Direct Mappings
        host_id,
        TRIM(meeting_topic) AS meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        
        -- Derived Attributes
        CASE 
            WHEN duration_minutes <= 30 THEN 'Short'
            WHEN duration_minutes <= 120 THEN 'Medium'
            ELSE 'Long'
        END AS meeting_type,
        
        'UTC' AS time_zone,
        
        CASE 
            WHEN duration_minutes <= 30 THEN 'Small'
            WHEN duration_minutes <= 120 THEN 'Medium'
            ELSE 'Large'
        END AS meeting_size_category,
        
        CASE 
            WHEN EXTRACT(hour FROM start_time) BETWEEN 9 AND 17 
                 AND EXTRACT(dow FROM start_time) BETWEEN 1 AND 5 
            THEN TRUE 
            ELSE FALSE 
        END AS business_hours_flag,
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system,
        start_time AS load_timestamp,
        COALESCE(update_timestamp, start_time) AS update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN host_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN meeting_topic IS NOT NULL AND LENGTH(TRIM(meeting_topic)) > 0 THEN 0.25 ELSE 0 END +
             CASE WHEN start_time IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN duration_minutes >= 0 AND duration_minutes <= 1440 THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_meetings
    WHERE row_num = 1
)

SELECT * FROM transformed_meetings

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
