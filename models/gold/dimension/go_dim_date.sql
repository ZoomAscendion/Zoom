{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_dim_date', 'SYSTEM_GENERATED', 'go_dim_date', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_dim_date' AND process_status = 'STARTED'"
) }}

-- Date dimension table for time-based analysis
WITH date_spine AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))
),

date_dimension AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY date_value) AS date_id,
        date_value,
        YEAR(date_value) AS year,
        QUARTER(date_value) AS quarter,
        MONTH(date_value) AS month,
        MONTHNAME(date_value) AS month_name,
        DAY(date_value) AS day_of_month,
        DAYOFWEEK(date_value) AS day_of_week,
        DAYNAME(date_value) AS day_name,
        CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        FALSE AS is_holiday,
        CASE 
            WHEN MONTH(date_value) >= 4 THEN YEAR(date_value)
            ELSE YEAR(date_value) - 1
        END AS fiscal_year,
        CASE 
            WHEN MONTH(date_value) IN (4, 5, 6) THEN 1
            WHEN MONTH(date_value) IN (7, 8, 9) THEN 2
            WHEN MONTH(date_value) IN (10, 11, 12) THEN 3
            ELSE 4
        END AS fiscal_quarter,
        WEEKOFYEAR(date_value) AS week_of_year,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'SYSTEM_GENERATED' AS source_system
    FROM date_spine
    WHERE date_value <= '2030-12-31'::DATE
)

SELECT * FROM date_dimension
