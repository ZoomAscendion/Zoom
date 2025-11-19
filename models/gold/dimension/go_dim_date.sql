{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (audit_log_id, process_name, process_type, execution_start_timestamp, execution_status, source_table_name, target_table_name, process_trigger, executed_by, load_date, source_system) VALUES ('{{ dbt_utils.generate_surrogate_key(['GO_DIM_DATE', run_started_at]) }}', 'GO_DIM_DATE_LOAD', 'DBT_MODEL', CURRENT_TIMESTAMP(), 'RUNNING', 'SYSTEM_GENERATED', 'GO_DIM_DATE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE audit_log_id = '{{ dbt_utils.generate_surrogate_key(['GO_DIM_DATE', run_started_at]) }}'"
) }}

-- Date dimension table generation
WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

date_dimension AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY date_day) AS date_id,
        date_day AS date_value,
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(MONTH FROM date_day) AS month,
        MONTHNAME(date_day) AS month_name,
        EXTRACT(DAY FROM date_day) AS day_of_month,
        DAYOFWEEK(date_day) AS day_of_week,
        DAYNAME(date_day) AS day_name,
        CASE WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        FALSE AS is_holiday, -- To be enhanced with holiday logic
        CASE 
            WHEN EXTRACT(MONTH FROM date_day) >= 4 THEN EXTRACT(YEAR FROM date_day)
            ELSE EXTRACT(YEAR FROM date_day) - 1
        END AS fiscal_year,
        CASE 
            WHEN EXTRACT(MONTH FROM date_day) IN (4, 5, 6) THEN 1
            WHEN EXTRACT(MONTH FROM date_day) IN (7, 8, 9) THEN 2
            WHEN EXTRACT(MONTH FROM date_day) IN (10, 11, 12) THEN 3
            ELSE 4
        END AS fiscal_quarter,
        WEEKOFYEAR(date_day) AS week_of_year,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'SYSTEM_GENERATED' AS source_system
    FROM date_spine
)

SELECT * FROM date_dimension
