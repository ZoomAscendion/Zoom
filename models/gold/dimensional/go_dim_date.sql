{{ config(
    materialized='table',
    cluster_by=['DATE_KEY']
) }}

-- Date Dimension Table
WITH date_spine AS (
    SELECT 
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years of dates
),

date_attributes AS (
    SELECT 
        date_value AS DATE_KEY,
        'DIM_DATE_' || TO_CHAR(date_value, 'YYYYMMDD') AS DIM_DATE_ID,
        YEAR(date_value) AS YEAR,
        QUARTER(date_value) AS QUARTER,
        MONTH(date_value) AS MONTH,
        MONTHNAME(date_value) AS MONTH_NAME,
        WEEKOFYEAR(date_value) AS WEEK_OF_YEAR,
        DAYOFMONTH(date_value) AS DAY_OF_MONTH,
        DAYOFWEEK(date_value) AS DAY_OF_WEEK,
        DAYNAME(date_value) AS DAY_NAME,
        CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
        FALSE AS IS_HOLIDAY, -- Default to false, updated via holiday calendar
        CASE 
            WHEN MONTH(date_value) >= 4 THEN YEAR(date_value) 
            ELSE YEAR(date_value) - 1 
        END AS FISCAL_YEAR,
        CASE 
            WHEN MONTH(date_value) BETWEEN 4 AND 6 THEN 1
            WHEN MONTH(date_value) BETWEEN 7 AND 9 THEN 2
            WHEN MONTH(date_value) BETWEEN 10 AND 12 THEN 3
            ELSE 4
        END AS FISCAL_QUARTER,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SYSTEM_GENERATED' AS SOURCE_SYSTEM
    FROM date_spine
)

SELECT * FROM date_attributes
