{{
  config(
    materialized='incremental',
    unique_key='webinar_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge'
  )
}}

-- Silver Webinars Table Transformation
-- Transforms bronze webinar data with attendance rate calculations and categorization

WITH bronze_webinars AS (
    SELECT 
        host_id,
        webinar_topic,
        start_time,
        end_time,
        registrants,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_webinars') }}
    WHERE host_id IS NOT NULL 
      AND webinar_topic IS NOT NULL
      AND start_time IS NOT NULL
      AND registrants >= 0
      AND (end_time IS NULL OR end_time >= start_time)
),

deduped_webinars AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY host_id, start_time, webinar_topic 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM bronze_webinars
),

transformed_webinars AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['host_id', 'start_time', 'webinar_topic']) }} AS webinar_id,
        
        -- Direct Mappings
        host_id,
        TRIM(webinar_topic) AS webinar_topic,
        start_time,
        end_time,
        
        -- Calculated Duration
        COALESCE(DATEDIFF(minute, start_time, end_time), 60) AS duration_minutes,
        
        registrants,
        
        -- Estimated Actual Attendees (70% of registrants as default)
        ROUND(registrants * 0.7) AS actual_attendees,
        
        -- Calculated Attendance Rate
        CASE 
            WHEN registrants > 0 
            THEN ROUND((registrants * 0.7 * 100.0) / registrants, 2)
            ELSE 0.00
        END AS attendance_rate,
        
        -- Webinar Category
        CASE 
            WHEN UPPER(webinar_topic) LIKE '%TRAINING%' OR UPPER(webinar_topic) LIKE '%EDUCATION%' THEN 'Training'
            WHEN UPPER(webinar_topic) LIKE '%PRODUCT%' OR UPPER(webinar_topic) LIKE '%DEMO%' THEN 'Product Demo'
            WHEN UPPER(webinar_topic) LIKE '%MARKETING%' OR UPPER(webinar_topic) LIKE '%SALES%' THEN 'Marketing'
            ELSE 'General'
        END AS webinar_category,
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system,
        load_timestamp,
        update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN host_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN webinar_topic IS NOT NULL AND LENGTH(TRIM(webinar_topic)) > 0 THEN 0.25 ELSE 0 END +
             CASE WHEN start_time IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN registrants >= 0 THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_webinars
    WHERE row_num = 1
)

SELECT * FROM transformed_webinars

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
