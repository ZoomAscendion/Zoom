{{ config(
    materialized='table',
    tags=['dimension'],
    cluster_by=['DATE_VALUE']
) }}

-- Date dimension table for time-based analysis across all fact tables
-- Generates comprehensive date attributes for 10-year period (2020-2030)

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

date_calculations AS (
    SELECT 
        date_day AS date_value,
        
        -- Basic date components
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(MONTH FROM date_day) AS month,
        MONTHNAME(date_day) AS month_name,
        EXTRACT(DAY FROM date_day) AS day_of_month,
        EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
        DAYNAME(date_day) AS day_name,
        
        -- Weekend and holiday flags
        CASE WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        CASE 
            WHEN EXTRACT(MONTH FROM date_day) = 1 AND EXTRACT(DAY FROM date_day) = 1 THEN TRUE  -- New Year
            WHEN EXTRACT(MONTH FROM date_day) = 7 AND EXTRACT(DAY FROM date_day) = 4 THEN TRUE  -- Independence Day
            WHEN EXTRACT(MONTH FROM date_day) = 12 AND EXTRACT(DAY FROM date_day) = 25 THEN TRUE -- Christmas
            ELSE FALSE 
        END AS is_holiday,
        
        -- Fiscal year (assuming April-March fiscal year)
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
        
        -- Week of year
        EXTRACT(WEEK FROM date_day) AS week_of_year,
        
        -- Formatted strings
        'Q' || EXTRACT(QUARTER FROM date_day) AS quarter_name,
        TO_CHAR(date_day, 'MON-YYYY') AS month_year
        
    FROM date_spine
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY date_value) AS date_id,
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
    quarter_name,
    month_year,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'DBT_GOLD_PIPELINE' AS source_system
    
FROM date_calculations
ORDER BY date_value
