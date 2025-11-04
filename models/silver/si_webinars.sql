{{ config(
    materialized='table'
) }}

-- Silver Layer Webinars Transformation
-- Source: Bronze.BZ_WEBINARS
-- Target: Silver.SI_WEBINARS
-- Description: Transforms and cleanses webinar data with engagement metrics

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
    FROM {{ source('bronze', 'bz_webinars') }}
    WHERE webinar_id IS NOT NULL
      AND host_id IS NOT NULL
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        webinar_id,
        host_id,
        
        -- Clean and standardize webinar topic
        CASE 
            WHEN webinar_topic IS NULL OR TRIM(webinar_topic) = '' THEN 'Untitled Webinar'
            ELSE TRIM(webinar_topic)
        END AS webinar_topic_clean,
        
        -- Validate and correct timestamps
        CASE 
            WHEN start_time IS NULL THEN CURRENT_TIMESTAMP()
            ELSE start_time
        END AS start_time_clean,
        
        CASE 
            WHEN end_time IS NULL OR end_time < start_time 
                THEN DATEADD('hour', 1, COALESCE(start_time, CURRENT_TIMESTAMP()))
            ELSE end_time
        END AS end_time_clean,
        
        -- Validate registrants count
        CASE 
            WHEN registrants IS NULL OR registrants < 0 THEN 0
            ELSE registrants
        END AS registrants_clean,
        
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_webinars
),

-- Add derived fields
derived_fields AS (
    SELECT 
        *,
        -- Calculate duration in minutes
        DATEDIFF('minute', start_time_clean, end_time_clean) AS duration_minutes,
        
        -- Derive attendees from registrants (simplified logic)
        CASE 
            WHEN registrants_clean > 0 THEN ROUND(registrants_clean * 0.75, 0)
            ELSE 0
        END AS attendees,
        
        -- Calculate attendance rate
        CASE 
            WHEN registrants_clean > 0 THEN 
                ROUND((ROUND(registrants_clean * 0.75, 0) / registrants_clean) * 100, 2)
            ELSE 0
        END AS attendance_rate
    FROM data_quality_checks
),

-- Calculate data quality score
quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        (
            CASE WHEN webinar_topic_clean != 'Untitled Webinar' THEN 0.25 ELSE 0 END +
            CASE WHEN start_time_clean IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN end_time_clean IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN registrants_clean >= 0 THEN 0.25 ELSE 0 END
        ) AS data_quality_score
    FROM derived_fields
),

-- Remove duplicates keeping the most recent record
deduped_webinars AS (
    SELECT 
        webinar_id,
        host_id,
        webinar_topic_clean AS webinar_topic,
        start_time_clean AS start_time,
        end_time_clean AS end_time,
        duration_minutes,
        registrants_clean AS registrants,
        attendees,
        attendance_rate,
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        ROW_NUMBER() OVER (PARTITION BY webinar_id ORDER BY update_timestamp DESC) AS rn
    FROM quality_scored
    WHERE data_quality_score >= {{ var('dq_score_threshold') }}
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
  AND start_time IS NOT NULL
  AND end_time IS NOT NULL
  AND duration_minutes > 0
