{{ config(
    materialized='table'
) }}

-- Silver Layer Webinars Table
-- Transforms Bronze webinars data with engagement metrics and validations

WITH bronze_webinars AS (
    SELECT *
    FROM {{ source('bronze', 'bz_webinars') }}
),

-- Data Quality Validations
validated_webinars AS (
    SELECT 
        w.*,
        CASE 
            WHEN w.webinar_id IS NULL THEN 'CRITICAL_MISSING_ID'
            WHEN w.host_id IS NULL THEN 'CRITICAL_MISSING_HOST_ID'
            WHEN w.start_time IS NULL THEN 'CRITICAL_MISSING_START_TIME'
            WHEN w.end_time IS NOT NULL AND w.end_time < w.start_time THEN 'CRITICAL_INVALID_TIME_SEQUENCE'
            WHEN w.registrants IS NOT NULL AND w.registrants < 0 THEN 'CRITICAL_NEGATIVE_REGISTRANTS'
            ELSE 'VALID'
        END AS data_quality_status,
        
        -- Calculate data quality score
        CASE 
            WHEN w.webinar_id IS NOT NULL 
                AND w.host_id IS NOT NULL
                AND w.start_time IS NOT NULL
                AND (w.end_time IS NULL OR w.end_time >= w.start_time)
                AND (w.registrants IS NULL OR w.registrants >= 0)
            THEN 1.00
            ELSE 0.65
        END AS data_quality_score,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY w.webinar_id ORDER BY w.update_timestamp DESC, w.load_timestamp DESC) AS rn
    FROM bronze_webinars w
    WHERE w.webinar_id IS NOT NULL
        AND w.host_id IS NOT NULL
        AND w.start_time IS NOT NULL
        AND (w.end_time IS NULL OR w.end_time >= w.start_time)
        AND (w.registrants IS NULL OR w.registrants >= 0)
),

-- Apply transformations
transformed_webinars AS (
    SELECT 
        vw.webinar_id,
        vw.host_id,
        TRIM(vw.webinar_topic) AS webinar_topic,
        vw.start_time,
        
        -- Handle missing end_time
        COALESCE(vw.end_time, DATEADD('hour', 1, vw.start_time)) AS end_time,
        
        -- Calculate duration
        CASE 
            WHEN vw.end_time IS NOT NULL 
            THEN DATEDIFF('minute', vw.start_time, vw.end_time)
            ELSE 60  -- Default 1 hour duration
        END AS duration_minutes,
        
        COALESCE(vw.registrants, 0) AS registrants,
        
        -- Calculate attendees (simulate 70-90% attendance rate)
        CASE 
            WHEN vw.registrants > 0 
            THEN ROUND(vw.registrants * (0.7 + (UNIFORM(0, 20, RANDOM()) / 100.0)))
            ELSE 0
        END AS attendees,
        
        -- Calculate attendance rate
        CASE 
            WHEN vw.registrants > 0 
            THEN ROUND((ROUND(vw.registrants * (0.7 + (UNIFORM(0, 20, RANDOM()) / 100.0))) / vw.registrants::FLOAT) * 100, 2)
            ELSE 0.00
        END AS attendance_rate,
        
        -- Metadata columns
        vw.load_timestamp,
        vw.update_timestamp,
        vw.source_system,
        vw.data_quality_score,
        DATE(vw.load_timestamp) AS load_date,
        DATE(vw.update_timestamp) AS update_date
    FROM validated_webinars vw
    WHERE vw.rn = 1
        AND vw.data_quality_status = 'VALID'
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
FROM transformed_webinars
