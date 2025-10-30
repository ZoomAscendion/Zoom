{{
  config(
    materialized='incremental',
    unique_key='webinar_id',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (audit_id, source_table, process_start_time, status, processed_by, load_date, source_system) SELECT '{{ invocation_id }}', 'SI_WEBINARS', CURRENT_TIMESTAMP(), 'STARTED', 'DBT', CURRENT_DATE(), 'DBT_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="UPDATE {{ ref('audit_log') }} SET process_end_time = CURRENT_TIMESTAMP(), status = 'SUCCESS' WHERE audit_id = '{{ invocation_id }}' AND source_table = 'SI_WEBINARS' AND '{{ this.name }}' != 'audit_log'"
  )
}}

WITH bronze_webinars AS (
    SELECT *
    FROM {{ ref('bz_webinars') }}
    WHERE WEBINAR_ID IS NOT NULL
        AND HOST_ID IS NOT NULL
        AND START_TIME IS NOT NULL
        AND END_TIME IS NOT NULL
        AND END_TIME >= START_TIME
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleaned_webinars AS (
    SELECT 
        WEBINAR_ID AS webinar_id,
        HOST_ID AS host_id,
        TRIM(WEBINAR_TOPIC) AS webinar_topic,
        START_TIME,
        END_TIME,
        DATEDIFF('minute', START_TIME, END_TIME) AS duration_minutes,
        REGISTRANTS,
        GREATEST(0, REGISTRANTS - FLOOR(REGISTRANTS * 0.2)) AS attendees,
        CASE 
            WHEN REGISTRANTS > 0 
            THEN ROUND((GREATEST(0, REGISTRANTS - FLOOR(REGISTRANTS * 0.2)) / REGISTRANTS::FLOAT) * 100, 2)
            ELSE 0
        END AS attendance_rate,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        {{ calculate_data_quality_score('si_webinars', ['WEBINAR_ID', 'HOST_ID', 'WEBINAR_TOPIC', 'START_TIME', 'END_TIME']) }} AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_webinars
),

deduped_webinars AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY webinar_id ORDER BY update_timestamp DESC) AS rn
    FROM cleaned_webinars
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
WHERE rn = 1
