{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (execution_id, pipeline_name, start_time, status, executed_by, source_tables_processed, target_tables_updated, load_date, update_date, source_system) SELECT CONCAT('WEB_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')), 'SI_WEBINARS_ETL', CURRENT_TIMESTAMP(), 'Started', 'DBT_PIPELINE', 'BZ_WEBINARS', 'SI_WEBINARS', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (execution_id, pipeline_name, end_time, status, executed_by, records_processed, load_date, update_date, source_system) SELECT CONCAT('WEB_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')), 'SI_WEBINARS_ETL', CURRENT_TIMESTAMP(), 'Completed', 'DBT_PIPELINE', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'audit_log'"
) }}

-- Silver Layer Webinars Table
-- Transforms Bronze webinars data with validation and engagement metrics

WITH bronze_webinars AS (
    SELECT 
        webinar_id,
        host_id,
        webinar_topic,
        start_time,
        end_time,
        registrants,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ ref('bz_webinars') }}
    WHERE webinar_id IS NOT NULL
      AND host_id IS NOT NULL
),

-- Data Quality Validations and Transformations
validated_webinars AS (
    SELECT 
        webinar_id,
        host_id,
        
        -- Standardize webinar topic
        CASE 
            WHEN webinar_topic IS NULL OR TRIM(webinar_topic) = '' THEN 'Untitled Webinar'
            ELSE TRIM(webinar_topic)
        END AS webinar_topic,
        
        -- Validate start time
        CASE 
            WHEN start_time IS NULL THEN CURRENT_TIMESTAMP()
            ELSE start_time
        END AS start_time,
        
        -- Validate end time
        CASE 
            WHEN end_time IS NULL OR end_time < start_time 
                THEN DATEADD('hour', 1, COALESCE(start_time, CURRENT_TIMESTAMP()))
            ELSE end_time
        END AS end_time,
        
        -- Calculate duration in minutes
        DATEDIFF('minute', 
            COALESCE(start_time, CURRENT_TIMESTAMP()),
            CASE 
                WHEN end_time IS NULL OR end_time < start_time 
                    THEN DATEADD('hour', 1, COALESCE(start_time, CURRENT_TIMESTAMP()))
                ELSE end_time
            END
        ) AS duration_minutes,
        
        -- Validate registrants
        CASE 
            WHEN registrants IS NULL OR registrants < 0 THEN 0
            ELSE registrants
        END AS registrants,
        
        -- Calculate attendees (simplified logic - 70% of registrants)
        CASE 
            WHEN registrants IS NULL OR registrants < 0 THEN 0
            ELSE ROUND(registrants * 0.7)
        END AS attendees,
        
        -- Calculate attendance rate
        CASE 
            WHEN registrants IS NULL OR registrants = 0 THEN 0.0
            ELSE ROUND((registrants * 0.7) / registrants * 100, 2)
        END AS attendance_rate,
        
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Calculate data quality score
        (
            CASE WHEN webinar_id IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN host_id IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN start_time IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN registrants IS NOT NULL AND registrants >= 0 THEN 0.25 ELSE 0 END
        ) AS data_quality_score
        
    FROM bronze_webinars
),

-- Remove duplicates - keep latest record
deduped_webinars AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY webinar_id ORDER BY update_timestamp DESC) AS rn
    FROM validated_webinars
)

SELECT 
    webinar_id,
    host_id,
    webinar_topic,
    start_time,
    end_time,
    duration_minutes,
    registrants,
    attendees,
    attendance_rate,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    DATE(load_timestamp) AS load_date,
    DATE(update_timestamp) AS update_date
FROM deduped_webinars
WHERE rn = 1
  AND start_time IS NOT NULL  -- Ensure no null start times in Silver layer
  AND end_time >= start_time  -- Ensure logical time sequence
