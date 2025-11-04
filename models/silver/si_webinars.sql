{{ config(
    materialized='table'
) }}

-- Silver Webinars Table - Cleaned webinar data with engagement metrics
-- Includes attendance rate calculation and duration validation

WITH bronze_webinars AS (
    SELECT *
    FROM {{ source('bronze', 'bz_webinars') }}
),

-- Data Quality Validation and Cleansing
webinars_cleaned AS (
    SELECT
        bw.webinar_id,
        bw.host_id,
        
        -- Clean and standardize webinar topic
        CASE 
            WHEN bw.webinar_topic IS NULL OR TRIM(bw.webinar_topic) = '' THEN 'Untitled Webinar'
            ELSE TRIM(bw.webinar_topic)
        END AS webinar_topic,
        
        -- Validate and correct timestamps
        CASE 
            WHEN bw.start_time IS NULL THEN CURRENT_TIMESTAMP()
            ELSE bw.start_time
        END AS start_time,
        
        CASE 
            WHEN bw.end_time IS NULL OR bw.end_time < bw.start_time 
                THEN DATEADD('hour', 1, bw.start_time)  -- Default 1 hour duration
            ELSE bw.end_time
        END AS end_time,
        
        -- Calculate duration in minutes
        CASE 
            WHEN bw.end_time IS NULL OR bw.end_time < bw.start_time
                THEN 60  -- Default 1 hour
            ELSE DATEDIFF('minute', bw.start_time, bw.end_time)
        END AS duration_minutes,
        
        -- Validate registrants count
        CASE 
            WHEN bw.registrants IS NULL OR bw.registrants < 0 THEN 0
            ELSE bw.registrants
        END AS registrants,
        
        -- Calculate attendees (assume 70% attendance rate)
        CASE 
            WHEN bw.registrants IS NULL OR bw.registrants < 0 THEN 0
            ELSE ROUND(bw.registrants * 0.70)
        END AS attendees,
        
        -- Calculate attendance rate
        CASE 
            WHEN bw.registrants IS NULL OR bw.registrants = 0 THEN 0.00
            ELSE ROUND((bw.registrants * 0.70 / bw.registrants) * 100, 2)
        END AS attendance_rate,
        
        -- Metadata columns
        bw.load_timestamp,
        bw.update_timestamp,
        bw.source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN bw.webinar_id IS NOT NULL 
                AND bw.host_id IS NOT NULL
                AND bw.start_time IS NOT NULL
                AND bw.end_time IS NOT NULL
                AND bw.end_time >= bw.start_time
                AND bw.registrants IS NOT NULL AND bw.registrants >= 0
                THEN 1.00
            WHEN bw.webinar_id IS NOT NULL AND bw.host_id IS NOT NULL
                THEN 0.75
            WHEN bw.webinar_id IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(bw.load_timestamp) AS load_date,
        DATE(bw.update_timestamp) AS update_date
        
    FROM bronze_webinars bw
    WHERE bw.webinar_id IS NOT NULL  -- Block records without webinar_id
        AND bw.host_id IS NOT NULL   -- Block records without host_id
),

-- Remove duplicates - keep latest record
webinars_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY webinar_id ORDER BY update_timestamp DESC) AS rn
    FROM webinars_cleaned
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
    load_date,
    update_date
FROM webinars_deduped
WHERE rn = 1
    AND data_quality_score >= 0.50  -- Only high quality records
    AND registrants >= 0            -- Ensure non-negative registrants
