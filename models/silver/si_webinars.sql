{{ config(
    materialized='table'
) }}

WITH bronze_webinars AS (
    SELECT *
    FROM {{ source('bronze', 'bz_webinars') }}
),

data_quality_checks AS (
    SELECT 
        *,
        -- Time validation
        CASE 
            WHEN start_time IS NOT NULL AND (end_time IS NULL OR end_time >= start_time) THEN 1
            ELSE 0
        END AS time_quality,
        
        -- Registrants validation
        CASE 
            WHEN registrants >= 0 THEN 1
            ELSE 0
        END AS registrants_quality,
        
        -- Host validation
        CASE 
            WHEN host_id IS NOT NULL THEN 1
            ELSE 0
        END AS host_quality,
        
        -- Completeness check
        CASE 
            WHEN webinar_id IS NOT NULL AND start_time IS NOT NULL THEN 1
            ELSE 0
        END AS completeness_quality
    FROM bronze_webinars
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY webinar_id 
            ORDER BY load_timestamp DESC, update_timestamp DESC
        ) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        webinar_id,
        host_id,
        COALESCE(TRIM(webinar_topic), 'Unknown Topic - needs enrichment') AS webinar_topic,
        start_time,
        CASE 
            WHEN end_time IS NULL THEN DATEADD('hour', 1, start_time)
            WHEN end_time < start_time THEN DATEADD('hour', 1, start_time)
            ELSE end_time
        END AS end_time,
        CASE 
            WHEN end_time IS NULL THEN 60
            WHEN end_time < start_time THEN 60
            ELSE DATEDIFF('minute', start_time, end_time)
        END AS duration_minutes,
        CASE 
            WHEN registrants < 0 THEN 0
            ELSE registrants
        END AS registrants,
        CASE 
            WHEN registrants < 0 THEN 0
            ELSE ROUND(registrants * 0.75)
        END AS attendees,
        CASE 
            WHEN registrants <= 0 THEN 0
            ELSE ROUND((registrants * 0.75 / registrants) * 100, 2)
        END AS attendance_rate,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Calculate data quality score
        ROUND(
            (time_quality + registrants_quality + host_quality + completeness_quality) / 4.0, 2
        ) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM deduplication
    WHERE rn = 1
      AND webinar_id IS NOT NULL
      AND host_id IS NOT NULL
      AND start_time IS NOT NULL
      AND registrants >= 0
)

SELECT * FROM final_transformation
