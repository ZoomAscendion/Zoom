{{ config(
    materialized='table',
    cluster_by=['DATE_VALUE'],
    tags=['dimension', 'date']
) }}

-- Standard date dimension for time-based analysis across all fact tables
-- Covers 10 years of data with comprehensive date attributes

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
        YEAR(date_day) AS year,
        QUARTER(date_day) AS quarter,
        MONTH(date_day) AS month,
        MONTHNAME(date_day) AS month_name,
        DAY(date_day) AS day_of_month,
        DAYOFWEEK(date_day) AS day_of_week,
        DAYNAME(date_day) AS day_name,
        
        -- Weekend and business day indicators
        CASE WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        CASE WHEN DAYOFWEEK(date_day) NOT IN (1, 7) THEN TRUE ELSE FALSE END AS is_business_day,
        
        -- Holiday indicator (basic US holidays)
        CASE 
            WHEN (MONTH(date_day) = 1 AND DAY(date_day) = 1) THEN TRUE  -- New Year
            WHEN (MONTH(date_day) = 7 AND DAY(date_day) = 4) THEN TRUE  -- Independence Day
            WHEN (MONTH(date_day) = 12 AND DAY(date_day) = 25) THEN TRUE -- Christmas
            ELSE FALSE 
        END AS is_holiday,
        
        -- Fiscal year calculations (assuming July 1 start)
        CASE 
            WHEN MONTH(date_day) >= 7 THEN YEAR(date_day) + 1 
            ELSE YEAR(date_day) 
        END AS fiscal_year,
        
        CASE 
            WHEN MONTH(date_day) IN (7, 8, 9) THEN 1
            WHEN MONTH(date_day) IN (10, 11, 12) THEN 2
            WHEN MONTH(date_day) IN (1, 2, 3) THEN 3
            WHEN MONTH(date_day) IN (4, 5, 6) THEN 4
        END AS fiscal_quarter,
        
        -- Week calculations
        WEEKOFYEAR(date_day) AS week_of_year,
        
        -- Formatted date strings
        'Q' || QUARTER(date_day) AS quarter_name,
        TO_CHAR(date_day, 'MON-YYYY') AS month_year,
        
        -- Relative date indicators
        CASE WHEN date_day = CURRENT_DATE() THEN TRUE ELSE FALSE END AS is_today,
        CASE WHEN date_day = CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_yesterday,
        CASE WHEN date_day BETWEEN CURRENT_DATE() - 7 AND CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_last_7_days,
        CASE WHEN date_day BETWEEN CURRENT_DATE() - 30 AND CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_last_30_days,
        
        -- Seasonal indicators
        CASE 
            WHEN MONTH(date_day) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(date_day) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(date_day) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(date_day) IN (9, 10, 11) THEN 'Fall'
        END AS season
        
    FROM date_spine
),

final_dimension AS (
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
        is_business_day,
        is_holiday,
        fiscal_year,
        fiscal_quarter,
        week_of_year,
        quarter_name,
        month_year,
        is_today,
        is_yesterday,
        is_last_7_days,
        is_last_30_days,
        season,
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'SYSTEM_GENERATED' AS source_system
        
    FROM date_calculations
)

SELECT * FROM final_dimension
ORDER BY date_value
