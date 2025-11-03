{{
    config(
        materialized='table',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Webinars Transformation
-- Transforms Bronze layer webinar data with engagement metrics

WITH bronze_webinars AS (
    SELECT 
        WEBINAR_ID,
        HOST_ID,
        WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        REGISTRANTS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_webinars') }}
    WHERE WEBINAR_ID IS NOT NULL
      AND HOST_ID IS NOT NULL
),

-- Data Quality Validations and Cleansing
webinars_cleaned AS (
    SELECT 
        WEBINAR_ID,
        HOST_ID,
        
        -- Clean and standardize webinar topic
        CASE 
            WHEN WEBINAR_TOPIC IS NULL OR TRIM(WEBINAR_TOPIC) = '' THEN 'Untitled Webinar'
            ELSE TRIM(WEBINAR_TOPIC)
        END AS WEBINAR_TOPIC,
        
        -- Validate and correct timestamps
        CASE 
            WHEN START_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN CURRENT_TIMESTAMP()
            ELSE START_TIME
        END AS START_TIME,
        
        CASE 
            WHEN END_TIME IS NULL THEN START_TIME + INTERVAL '1' HOUR  -- Default 1 hour duration
            WHEN END_TIME < START_TIME THEN START_TIME + INTERVAL '1' HOUR
            WHEN END_TIME > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN CURRENT_TIMESTAMP()
            ELSE END_TIME
        END AS END_TIME,
        
        -- Validate registrants count
        CASE 
            WHEN REGISTRANTS < 0 THEN 0
            WHEN REGISTRANTS IS NULL THEN 0
            ELSE REGISTRANTS
        END AS REGISTRANTS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_webinars
),

-- Calculate webinar metrics
webinars_with_metrics AS (
    SELECT 
        *,
        -- Calculate duration in minutes
        DATEDIFF('minute', START_TIME, END_TIME) AS DURATION_MINUTES,
        
        -- Estimate attendees (typically 60-80% of registrants)
        CASE 
            WHEN REGISTRANTS = 0 THEN 0
            ELSE ROUND(REGISTRANTS * 0.7, 0)
        END AS ATTENDEES,
        
        -- Calculate attendance rate
        CASE 
            WHEN REGISTRANTS = 0 THEN 0.0
            ELSE ROUND((REGISTRANTS * 0.7 / REGISTRANTS) * 100, 2)
        END AS ATTENDANCE_RATE,
        
        -- Calculate data quality score
        (
            CASE WHEN WEBINAR_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN HOST_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN START_TIME IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN END_TIME IS NOT NULL AND END_TIME >= START_TIME THEN 0.2 ELSE 0 END +
            CASE WHEN REGISTRANTS >= 0 THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM webinars_cleaned
),

-- Remove duplicates keeping the latest record
webinars_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY WEBINAR_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM webinars_with_metrics
)

SELECT 
    WEBINAR_ID,
    HOST_ID,
    WEBINAR_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    REGISTRANTS,
    ATTENDEES,
    ATTENDANCE_RATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM webinars_deduped
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.80  -- Only allow records with at least 80% data quality
