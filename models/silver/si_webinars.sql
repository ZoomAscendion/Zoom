{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('si_pipeline_audit') }} (
            execution_id, pipeline_name, start_time, status, 
            source_tables_processed, executed_by, execution_environment,
            load_date, update_date, source_system
        )
        VALUES (
            '{{ invocation_id }}_si_webinars', 
            'si_webinars', 
            CURRENT_TIMESTAMP(), 
            'STARTED',
            'BZ_WEBINARS',
            '{{ var(\"audit_user\") }}',
            'PRODUCTION',
            CURRENT_DATE(),
            CURRENT_DATE(),
            'DBT_SILVER_PIPELINE'
        )
    ",
    post_hook="
        UPDATE {{ ref('si_pipeline_audit') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
            target_tables_updated = 'SI_WEBINARS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            records_inserted = (SELECT COUNT(*) FROM {{ this }}),
            records_updated = 0,
            records_rejected = 0,
            update_date = CURRENT_DATE()
        WHERE execution_id = '{{ invocation_id }}_si_webinars'
    "
) }}

-- Silver layer transformation for Webinars
WITH bronze_webinars AS (
    SELECT *
    FROM {{ source('bronze', 'bz_webinars') }}
),

-- Data Quality Checks and Cleansing
cleansed_webinars AS (
    SELECT 
        webinar_id,
        host_id,
        TRIM(webinar_topic) AS webinar_topic_clean,
        start_time,
        end_time,
        registrants,
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data Quality Validations
        CASE 
            WHEN webinar_id IS NULL THEN 0
            WHEN host_id IS NULL THEN 0
            WHEN start_time IS NULL THEN 0
            WHEN registrants IS NOT NULL AND registrants < 0 THEN 0
            WHEN end_time IS NOT NULL AND end_time < start_time THEN 0
            ELSE 1
        END AS webinar_valid,
        
        -- Corrected end_time if missing or invalid
        CASE 
            WHEN end_time IS NULL 
            THEN DATEADD('hour', 1, start_time)
            WHEN end_time < start_time 
            THEN DATEADD('hour', 1, start_time)
            ELSE end_time
        END AS end_time_corrected,
        
        -- Corrected registrants if negative
        CASE 
            WHEN registrants IS NULL OR registrants < 0 THEN 0
            ELSE registrants
        END AS registrants_corrected
        
    FROM bronze_webinars
),

-- Remove duplicates
deduped_webinars AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY webinar_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS rn
    FROM cleansed_webinars
    WHERE webinar_valid = 1
),

-- Final transformation with derived fields
final_webinars AS (
    SELECT 
        webinar_id,
        host_id,
        COALESCE(webinar_topic_clean, 'Untitled Webinar') AS webinar_topic,
        start_time,
        end_time_corrected AS end_time,
        
        -- Calculate duration
        DATEDIFF('minute', start_time, end_time_corrected) AS duration_minutes,
        
        registrants_corrected AS registrants,
        
        -- Derive attendees (assume 70% attendance rate)
        ROUND(registrants_corrected * 0.70) AS attendees,
        
        -- Calculate attendance rate
        CASE 
            WHEN registrants_corrected > 0 
            THEN ROUND((ROUND(registrants_corrected * 0.70) / registrants_corrected) * 100, 2)
            ELSE 0.00
        END AS attendance_rate,
        
        -- Metadata columns
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data quality score
        CASE 
            WHEN webinar_id IS NOT NULL 
                AND host_id IS NOT NULL 
                AND start_time IS NOT NULL 
                AND end_time_corrected IS NOT NULL
            THEN 1.00
            ELSE 0.75
        END AS data_quality_score,
        
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
        
    FROM deduped_webinars
    WHERE rn = 1
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
FROM final_webinars
