{{ config(
    materialized='table',
    schema='gold',
    tags=['dimension', 'date'],
    unique_key='date_id'
) }}

-- Date dimension table for Gold layer
-- Generates a comprehensive date dimension from 2020 to 2030

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" + var('start_date') + "' as date)",
        end_date="cast('" + var('end_date') + "' as date)"
    ) }}
),

date_calculations AS (
    SELECT 
        date_day,
        
        -- Generate surrogate key
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} AS date_id,
        
        -- Basic date components
        date_day AS date_value,
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(MONTH FROM date_day) AS month,
        MONTHNAME(date_day) AS month_name,
        EXTRACT(DAY FROM date_day) AS day_of_month,
        EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
        DAYNAME(date_day) AS day_name,
        
        -- Weekend indicator
        CASE 
            WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN TRUE 
            ELSE FALSE 
        END AS is_weekend,
        
        -- Holiday indicator (basic US holidays)
        CASE 
            WHEN (EXTRACT(MONTH FROM date_day) = 1 AND EXTRACT(DAY FROM date_day) = 1) THEN TRUE  -- New Year's Day
            WHEN (EXTRACT(MONTH FROM date_day) = 7 AND EXTRACT(DAY FROM date_day) = 4) THEN TRUE  -- Independence Day
            WHEN (EXTRACT(MONTH FROM date_day) = 12 AND EXTRACT(DAY FROM date_day) = 25) THEN TRUE -- Christmas
            ELSE FALSE
        END AS is_holiday,
        
        -- Fiscal year (assuming fiscal year starts in January)
        CASE 
            WHEN EXTRACT(MONTH FROM date_day) >= 1 THEN EXTRACT(YEAR FROM date_day)
            ELSE EXTRACT(YEAR FROM date_day) - 1
        END AS fiscal_year,
        
        -- Fiscal quarter
        CASE 
            WHEN EXTRACT(MONTH FROM date_day) IN (1, 2, 3) THEN 1
            WHEN EXTRACT(MONTH FROM date_day) IN (4, 5, 6) THEN 2
            WHEN EXTRACT(MONTH FROM date_day) IN (7, 8, 9) THEN 3
            WHEN EXTRACT(MONTH FROM date_day) IN (10, 11, 12) THEN 4
        END AS fiscal_quarter,
        
        -- Week of year
        EXTRACT(WEEK FROM date_day) AS week_of_year,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        '{{ var("source_system") }}' AS source_system
        
    FROM date_spine
)

SELECT 
    date_id,
    date_value,
    year,
    quarter,
    month,
    month_name,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend,
    is_holiday,
    fiscal_year,
    fiscal_quarter,
    week_of_year,
    load_date,
    update_date,
    source_system
FROM date_calculations
ORDER BY date_value