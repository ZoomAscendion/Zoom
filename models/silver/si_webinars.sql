{{ config(
    materialized='incremental',
    unique_key='webinar_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Webinars data
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
    
    {% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleansed_webinars AS (
    SELECT 
        TRIM(WEBINAR_ID) AS webinar_id,
        TRIM(HOST_ID) AS host_id,
        TRIM(WEBINAR_TOPIC) AS webinar_topic,
        START_TIME AS start_time,
        END_TIME AS end_time,
        CASE 
            WHEN END_TIME > START_TIME THEN DATEDIFF('minute', START_TIME, END_TIME)
            ELSE 0
        END AS duration_minutes,
        COALESCE(REGISTRANTS, 0) AS registrants,
        ROUND(REGISTRANTS * 0.75, 0) AS attendees,  -- Estimated 75% attendance rate
        CASE 
            WHEN REGISTRANTS > 0 THEN ROUND((REGISTRANTS * 0.75) / REGISTRANTS * 100, 2)
            ELSE 0
        END AS attendance_rate,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        CASE 
            WHEN WEBINAR_ID IS NOT NULL AND HOST_ID IS NOT NULL AND START_TIME IS NOT NULL
            THEN 1.00
            ELSE 0.70
        END AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_webinars
    WHERE WEBINAR_ID IS NOT NULL
        AND REGISTRANTS >= 0
),

deduped_webinars AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY webinar_id 
            ORDER BY update_timestamp DESC
        ) AS row_num
    FROM cleansed_webinars
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
FROM deduped_webinars
WHERE row_num = 1
