{{ config(
    materialized='incremental',
    unique_key='webinar_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Webinars
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
        AND START_TIME IS NOT NULL
        AND END_TIME IS NOT NULL
        AND END_TIME >= START_TIME
        AND REGISTRANTS >= 0
),

-- Data Quality Checks and Cleansing
cleansed_webinars AS (
    SELECT 
        TRIM(WEBINAR_ID) as WEBINAR_ID,
        TRIM(HOST_ID) as HOST_ID,
        TRIM(WEBINAR_TOPIC) as WEBINAR_TOPIC,
        START_TIME,
        END_TIME,
        GREATEST(DATEDIFF('minute', START_TIME, END_TIME), 0) as DURATION_MINUTES,
        REGISTRANTS,
        GREATEST(REGISTRANTS * 0.7, 0) as ATTENDEES, -- Estimated 70% attendance
        CASE 
            WHEN REGISTRANTS > 0 THEN ROUND((REGISTRANTS * 0.7 / REGISTRANTS) * 100, 2)
            ELSE 0
        END as ATTENDANCE_RATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_webinars
),

-- Remove duplicates
deduped_webinars AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY WEBINAR_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM cleansed_webinars
),

-- Calculate data quality score
final_webinars AS (
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
        -- Calculate data quality score
        ROUND(
            (CASE WHEN WEBINAR_TOPIC IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN DURATION_MINUTES >= 0 THEN 0.2 ELSE 0 END +
             CASE WHEN REGISTRANTS >= 0 THEN 0.2 ELSE 0 END +
             CASE WHEN ATTENDEES >= 0 THEN 0.2 ELSE 0 END +
             CASE WHEN ATTENDANCE_RATE >= 0 THEN 0.2 ELSE 0 END), 2
        ) as DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduped_webinars
    WHERE rn = 1
)

SELECT * FROM final_webinars

{% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
