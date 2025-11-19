{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_DIM_MEETING_TYPE', run_started_at]) }}', 'GO_DIM_MEETING_TYPE_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_MEETINGS', 'GO_DIM_MEETING_TYPE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_DIM_MEETING_TYPE', run_started_at]) }}'"
) }}

-- Meeting type dimension transformation from Silver layer
WITH meeting_source AS (
    SELECT DISTINCT
        COALESCE(duration_minutes, 30) AS duration_minutes,
        COALESCE(start_time, CURRENT_TIMESTAMP()) AS start_time,
        COALESCE(data_quality_score, 80) AS data_quality_score,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM {{ source('gold', 'si_meetings') }}
    WHERE validation_status = 'PASSED'
),

meeting_type_transformed AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY meeting_category, duration_category, time_of_day_category) AS meeting_type_id,
        {{ dbt_utils.generate_surrogate_key(['meeting_category', 'duration_category', 'time_of_day_category']) }} AS meeting_type_key,
        'Standard Meeting' AS meeting_type,
        CASE 
            WHEN duration_minutes <= 15 THEN 'Quick Sync'
            WHEN duration_minutes <= 60 THEN 'Standard Meeting'
            WHEN duration_minutes <= 120 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END AS meeting_category,
        CASE 
            WHEN duration_minutes <= 15 THEN 'Brief'
            WHEN duration_minutes <= 60 THEN 'Standard'
            WHEN duration_minutes <= 120 THEN 'Extended'
            ELSE 'Long'
        END AS duration_category,
        'Unknown' AS participant_size_category,
        CASE 
            WHEN EXTRACT(HOUR FROM start_time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM start_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM start_time) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day_category,
        DAYNAME(start_time) AS day_of_week,
        CASE WHEN DAYOFWEEK(start_time) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend_meeting,
        FALSE AS is_recurring_type,
        CASE 
            WHEN data_quality_score >= 90 THEN 9.0
            WHEN data_quality_score >= 80 THEN 8.0
            WHEN data_quality_score >= 70 THEN 7.0
            ELSE 6.0
        END AS meeting_quality_threshold,
        'Standard meeting features' AS typical_features_used,
        'Business Meeting' AS business_purpose,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM meeting_source
)

SELECT DISTINCT * FROM meeting_type_transformed
