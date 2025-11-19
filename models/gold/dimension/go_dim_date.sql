{{ config(
    materialized='table'
) }}

-- Date dimension table for time-based analysis
-- Generates dates from 2020-01-01 to 2030-12-31

WITH date_spine AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '{{ var("start_date") }}'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))  -- 11 years of dates
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
        CASE 
            WHEN (MONTH(date_value) = 1 AND DAY(date_value) = 1) OR  -- New Year
                 (MONTH(date_value) = 7 AND DAY(date_value) = 4) OR  -- Independence Day
                 (MONTH(date_value) = 12 AND DAY(date_value) = 25)   -- Christmas
            THEN TRUE 
            ELSE FALSE 
        END AS is_holiday,
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
    WHERE date_value <= '{{ var("end_date") }}'::DATE
)

SELECT * FROM date_dimension
