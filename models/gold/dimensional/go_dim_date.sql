{{ config(materialized='table') }}

-- Date Dimension Table
WITH date_range AS (
    SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 1095)) -- 3 years of dates
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY date_value) AS DATE_ID,
    date_value AS DATE_VALUE,
    YEAR(date_value) AS YEAR,
    QUARTER(date_value) AS QUARTER,
    MONTH(date_value) AS MONTH,
    MONTHNAME(date_value) AS MONTH_NAME,
    DAY(date_value) AS DAY_OF_MONTH,
    DAYOFWEEK(date_value) AS DAY_OF_WEEK,
    DAYNAME(date_value) AS DAY_NAME,
    CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
    FALSE AS IS_HOLIDAY,
    YEAR(date_value) AS FISCAL_YEAR,
    QUARTER(date_value) AS FISCAL_QUARTER,
    WEEKOFYEAR(date_value) AS WEEK_OF_YEAR,
    'Q' || QUARTER(date_value) AS QUARTER_NAME,
    TO_CHAR(date_value, 'MON-YYYY') AS MONTH_YEAR,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SYSTEM_GENERATED' AS SOURCE_SYSTEM
FROM date_range
