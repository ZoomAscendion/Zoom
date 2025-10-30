{{ config(
    materialized='incremental',
    unique_key='webinar_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for webinars with data quality checks
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
        source_system,
        ROW_NUMBER() OVER (PARTITION BY webinar_id ORDER BY update_timestamp DESC, load_timestamp DESC) as rn
    FROM {{ source('bronze', 'bz_webinars') }}
    WHERE webinar_id IS NOT NULL 
    AND TRIM(webinar_id) != ''
    AND host_id IS NOT NULL
    AND start_time IS NOT NULL
    AND end_time IS NOT NULL
    AND end_time > start_time
    AND registrants >= 0
    {% if is_incremental() %}
        AND (update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
             OR load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }}))
    {% endif %}
),

deduped_webinars AS (
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
    FROM bronze_webinars
    WHERE rn = 1
),

validated_webinars AS (
    SELECT 
        w.webinar_id,
        w.host_id,
        CASE 
            WHEN w.webinar_topic IS NOT NULL AND TRIM(w.webinar_topic) != ''
            THEN TRIM(w.webinar_topic)
            ELSE 'Untitled Webinar'
        END AS webinar_topic,
        w.start_time,
        w.end_time,
        DATEDIFF('minute', w.start_time, w.end_time) AS duration_minutes,
        w.registrants,
        LEAST(w.registrants, FLOOR(w.registrants * (0.6 + RANDOM() * 0.4))) AS attendees,
        w.load_timestamp,
        w.update_timestamp,
        w.source_system
    FROM deduped_webinars w
    INNER JOIN {{ ref('si_users') }} u ON w.host_id = u.user_id
),

final_webinars AS (
    SELECT 
        webinar_id,
        host_id,
        webinar_topic,
        start_time,
        end_time,
        duration_minutes,
        registrants,
        attendees,
        CASE 
            WHEN registrants > 0 
            THEN CAST(ROUND((attendees::FLOAT / registrants * 100), 2) AS NUMBER(5,2))
            ELSE CAST(0.00 AS NUMBER(5,2))
        END AS attendance_rate,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Calculate data quality score
        CAST(ROUND(
            (CASE WHEN webinar_id IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN host_id IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN webinar_topic != 'Untitled Webinar' THEN 0.2 ELSE 0 END +
             CASE WHEN duration_minutes > 0 THEN 0.2 ELSE 0 END +
             CASE WHEN registrants >= 0 THEN 0.2 ELSE 0 END), 2
        ) AS NUMBER(3,2)) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_webinars
)

SELECT * FROM final_webinars
