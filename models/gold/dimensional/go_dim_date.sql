{{ config(
    materialized='table'
) }}

-- Date dimension table for time-based analysis
-- Generates dates from 2020-01-01 to 2030-12-31

WITH date_spine AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))
),

date_dimension AS (
    SELECT 
        date_day AS DATE_VALUE,
        ROW_NUMBER() OVER (ORDER BY date_day) AS DATE_ID,
        YEAR(date_day) AS YEAR,
        QUARTER(date_day) AS QUARTER,
        MONTH(date_day) AS MONTH,
        MONTHNAME(date_day) AS MONTH_NAME,
        DAY(date_day) AS DAY_OF_MONTH,
        DAYOFWEEK(date_day) AS DAY_OF_WEEK,
        DAYNAME(date_day) AS DAY_NAME,
        CASE WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
        FALSE AS IS_HOLIDAY,
        CASE 
            WHEN MONTH(date_day) >= 4 THEN YEAR(date_day)
            ELSE YEAR(date_day) - 1
        END AS FISCAL_YEAR,
        CASE 
            WHEN MONTH(date_day) IN (4, 5, 6) THEN 1
            WHEN MONTH(date_day) IN (7, 8, 9) THEN 2
            WHEN MONTH(date_day) IN (10, 11, 12) THEN 3
            ELSE 4
        END AS FISCAL_QUARTER,
        WEEKOFYEAR(date_day) AS WEEK_OF_YEAR,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SYSTEM_GENERATED' AS SOURCE_SYSTEM
    FROM date_spine
)

SELECT * FROM date_dimension
