{{ config(
    materialized='table'
) }}

-- Date Dimension Generation
-- Creates a comprehensive date dimension for time-based analysis

WITH date_range AS (
    SELECT 
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years of dates
),

date_attributes AS (
    SELECT 
        date_value AS DATE_KEY,
        date_value AS DATE_VALUE,
        YEAR(date_value) AS YEAR,
        QUARTER(date_value) AS QUARTER,
        MONTH(date_value) AS MONTH,
        MONTHNAME(date_value) AS MONTH_NAME,
        DAY(date_value) AS DAY_OF_MONTH,
        DAYOFWEEK(date_value) AS DAY_OF_WEEK,
        DAYNAME(date_value) AS DAY_NAME,
        CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
        FALSE AS IS_HOLIDAY, -- To be updated with holiday logic
        CASE 
            WHEN MONTH(date_value) >= 4 THEN YEAR(date_value) 
            ELSE YEAR(date_value) - 1 
        END AS FISCAL_YEAR,
        CASE 
            WHEN MONTH(date_value) >= 4 THEN QUARTER(date_value) 
            ELSE QUARTER(date_value) + 4 
        END AS FISCAL_QUARTER,
        WEEKOFYEAR(date_value) AS WEEK_OF_YEAR,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SYSTEM_GENERATED' AS SOURCE_SYSTEM
    FROM date_range
    WHERE date_value <= CURRENT_DATE() + INTERVAL '2 years'
)

SELECT 
    DATE_KEY,
    DATE_VALUE,
    YEAR,
    QUARTER,
    MONTH,
    MONTH_NAME,
    DAY_OF_MONTH,
    DAY_OF_WEEK,
    DAY_NAME,
    IS_WEEKEND,
    IS_HOLIDAY,
    FISCAL_YEAR,
    FISCAL_QUARTER,
    WEEK_OF_YEAR,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM date_attributes
