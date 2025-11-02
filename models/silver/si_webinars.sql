{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_WEBINARS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_WEBINARS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_WEBINARS', 'SI_WEBINARS', 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, records_inserted, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_WEBINARS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_WEBINARS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Webinars Model
WITH bronze_webinars AS (
    SELECT * FROM {{ source('bronze', 'bz_webinars') }}
),

silver_users AS (
    SELECT * FROM {{ ref('si_users') }}
),

data_quality_checks AS (
    SELECT 
        *,
        CASE 
            WHEN end_time < start_time THEN 'INVALID_TIME_SEQUENCE'
            WHEN registrants < 0 THEN 'NEGATIVE_REGISTRANTS'
            ELSE 'VALID'
        END AS quality_flag
    FROM bronze_webinars
    WHERE webinar_id IS NOT NULL
      AND host_id IS NOT NULL
),

cleansed_webinars AS (
    SELECT 
        w.webinar_id,
        w.host_id,
        TRIM(w.webinar_topic) AS webinar_topic,
        w.start_time,
        CASE 
            WHEN w.quality_flag = 'INVALID_TIME_SEQUENCE'
            THEN w.start_time + INTERVAL '1' HOUR
            WHEN w.end_time IS NULL
            THEN w.start_time + INTERVAL '1' HOUR
            ELSE w.end_time
        END AS end_time,
        CASE 
            WHEN w.quality_flag = 'INVALID_TIME_SEQUENCE'
            THEN 60
            WHEN w.end_time IS NULL
            THEN 60
            ELSE DATEDIFF('minute', w.start_time, w.end_time)
        END AS duration_minutes,
        CASE 
            WHEN w.quality_flag = 'NEGATIVE_REGISTRANTS' THEN 0
            ELSE w.registrants
        END AS registrants,
        CASE 
            WHEN w.quality_flag = 'NEGATIVE_REGISTRANTS' THEN 0
            ELSE ROUND(w.registrants * 0.75)
        END AS attendees,
        CASE 
            WHEN w.registrants > 0
            THEN ROUND((ROUND(w.registrants * 0.75) / w.registrants) * 100, 2)
            ELSE 0
        END AS attendance_rate,
        w.load_timestamp,
        w.update_timestamp,
        w.source_system,
        ROUND(
            (CASE WHEN w.quality_flag = 'VALID' THEN 0.5 ELSE 0.0 END +
             CASE WHEN u.user_id IS NOT NULL THEN 0.3 ELSE 0.0 END +
             CASE WHEN w.webinar_topic IS NOT NULL THEN 0.2 ELSE 0.0 END), 2
        ) AS data_quality_score,
        DATE(w.load_timestamp) AS load_date,
        DATE(w.update_timestamp) AS update_date
    FROM data_quality_checks w
    LEFT JOIN silver_users u ON w.host_id = u.user_id
    WHERE u.user_id IS NOT NULL
),

deduped_webinars AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY webinar_id ORDER BY update_timestamp DESC) AS rn
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
WHERE rn = 1
