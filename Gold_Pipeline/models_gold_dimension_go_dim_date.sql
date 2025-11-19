{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['dimension', 'date']
) }}

-- Date dimension table generation from 2020 to 2030
-- Provides comprehensive date attributes for fact table joins

WITH date_spine AS (
    SELECT 
        DATEADD('day', ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 2020-01-01 to 2030-12-31
),

date_attributes AS (
    SELECT 
        date_value,
        
        -- Basic date components
        YEAR(date_value) AS year_num,
        QUARTER(date_value) AS quarter_num,
        MONTH(date_value) AS month_num,
        DAY(date_value) AS day_of_month,
        DAYOFWEEK(date_value) AS day_of_week_num,
        DAYOFYEAR(date_value) AS day_of_year,
        WEEKOFYEAR(date_value) AS week_of_year,
        
        -- Formatted names
        MONTHNAME(date_value) AS month_name,
        DAYNAME(date_value) AS day_name,
        
        -- Weekend and holiday flags
        CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        
        -- Fiscal year (assuming fiscal year starts in January)
        CASE 
            WHEN MONTH(date_value) >= 1 THEN YEAR(date_value)
            ELSE YEAR(date_value) - 1
        END AS fiscal_year,
        
        CASE 
            WHEN MONTH(date_value) IN (1, 2, 3) THEN 1
            WHEN MONTH(date_value) IN (4, 5, 6) THEN 2
            WHEN MONTH(date_value) IN (7, 8, 9) THEN 3
            ELSE 4
        END AS fiscal_quarter,
        
        -- Holiday detection (basic US holidays)
        CASE 
            WHEN MONTH(date_value) = 1 AND DAY(date_value) = 1 THEN TRUE  -- New Year's Day
            WHEN MONTH(date_value) = 7 AND DAY(date_value) = 4 THEN TRUE  -- Independence Day
            WHEN MONTH(date_value) = 12 AND DAY(date_value) = 25 THEN TRUE -- Christmas
            ELSE FALSE
        END AS is_holiday
    FROM date_spine
    WHERE date_value <= '2030-12-31'
)

SELECT 
    MD5(CONCAT('DATE_', date_value::STRING)) AS date_id,
    date_value,
    year_num AS year,
    quarter_num AS quarter,
    month_num AS month,
    month_name,
    day_of_month,
    day_of_week_num AS day_of_week,
    day_name,
    is_weekend,
    is_holiday,
    fiscal_year,
    fiscal_quarter,
    week_of_year,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'SYSTEM_GENERATED' AS source_system
FROM date_attributes
ORDER BY date_value