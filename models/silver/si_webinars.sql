{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ log("Starting transformation for si_webinars", info=True) }}
{% endif %}

WITH source_data AS (
    SELECT 
        w.WEBINAR_ID,
        w.HOST_ID,
        w.WEBINAR_TOPIC,
        w.START_TIME,
        w.END_TIME,
        w.REGISTRANTS,
        w.LOAD_TIMESTAMP,
        w.UPDATE_TIMESTAMP,
        w.SOURCE_SYSTEM
    FROM {{ ref('bz_webinars') }} w
    WHERE w.WEBINAR_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        s.*,
        
        -- Time validation
        CASE 
            WHEN s.START_TIME IS NOT NULL AND s.END_TIME IS NOT NULL 
                 AND s.END_TIME >= s.START_TIME THEN 1
            ELSE 0
        END AS time_valid,
        
        -- Registrants validation
        CASE 
            WHEN s.REGISTRANTS >= 0 THEN 1
            ELSE 0
        END AS registrants_valid,
        
        -- Topic validation
        CASE 
            WHEN s.WEBINAR_TOPIC IS NOT NULL AND TRIM(s.WEBINAR_TOPIC) != '' THEN 1
            ELSE 0
        END AS topic_valid
    FROM source_data s
),

cleaned_data AS (
    SELECT 
        WEBINAR_ID,
        HOST_ID,
        
        -- Clean webinar topic
        CASE 
            WHEN topic_valid = 1 
            THEN TRIM(WEBINAR_TOPIC)
            ELSE 'UNTITLED_WEBINAR'
        END AS WEBINAR_TOPIC,
        
        -- Validate and clean timestamps
        CASE 
            WHEN time_valid = 1 THEN START_TIME
            ELSE NULL
        END AS START_TIME,
        
        CASE 
            WHEN time_valid = 1 THEN END_TIME
            WHEN START_TIME IS NOT NULL 
            THEN DATEADD('hour', 1, START_TIME)  -- Default 1 hour webinar
            ELSE NULL
        END AS END_TIME,
        
        -- Calculate duration
        CASE 
            WHEN time_valid = 1 AND START_TIME IS NOT NULL AND END_TIME IS NOT NULL
            THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE 60  -- Default 60 minutes
        END AS DURATION_MINUTES,
        
        -- Validate registrants
        CASE 
            WHEN registrants_valid = 1 THEN REGISTRANTS
            ELSE 0
        END AS REGISTRANTS,
        
        -- Derive attendees (assume 70% attendance rate)
        CASE 
            WHEN registrants_valid = 1 AND REGISTRANTS > 0
            THEN ROUND(REGISTRANTS * 0.7)
            ELSE 0
        END AS ATTENDEES,
        
        -- Calculate attendance rate
        CASE 
            WHEN REGISTRANTS > 0 
            THEN ROUND((ATTENDEES::FLOAT / REGISTRANTS::FLOAT) * 100, 2)
            ELSE 0.00
        END AS ATTENDANCE_RATE,
        
        -- Calculate data quality score
        ROUND((time_valid + registrants_valid + topic_valid) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM data_quality_checks
    WHERE WEBINAR_ID IS NOT NULL  -- Remove records with null primary key
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY WEBINAR_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    UPDATE_DATE,
    created_at,
    updated_at
FROM deduplication

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ log("Completed transformation for si_webinars", info=True) }}
{% endif %}
