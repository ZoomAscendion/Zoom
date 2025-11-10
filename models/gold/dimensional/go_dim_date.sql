{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_DIM_DATE_TRANSFORMATION', 'SYSTEM_GENERATED', 'GO_DIM_DATE', CURRENT_TIMESTAMP(), 'STARTED', 'Date dimension transformation started', CURRENT_DATE(), CURRENT_DATE())",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, PROCESS_STATUS, PROCESS_NOTES, LOAD_DATE, UPDATE_DATE) VALUES ('GO_DIM_DATE_TRANSFORMATION', 'SYSTEM_GENERATED', 'GO_DIM_DATE', CURRENT_TIMESTAMP(), 'COMPLETED', 'Date dimension transformation completed successfully', CURRENT_DATE(), CURRENT_DATE())"
) }}

-- Date Dimension Table
-- Generates a comprehensive date dimension for time-based analysis

WITH date_range AS (
    SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years of dates
),

date_attributes AS (
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
        CASE 
            WHEN MONTH(date_value) <= 6 THEN YEAR(date_value) 
            ELSE YEAR(date_value) + 1 
        END AS FISCAL_YEAR,
        CASE 
            WHEN MONTH(date_value) <= 6 THEN QUARTER(date_value) + 2 
            ELSE QUARTER(date_value) - 2 
        END AS FISCAL_QUARTER,
        WEEKOFYEAR(date_value) AS WEEK_OF_YEAR,
        'Q' || QUARTER(date_value) AS QUARTER_NAME,
        TO_CHAR(date_value, 'MON-YYYY') AS MONTH_YEAR,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SYSTEM_GENERATED' AS SOURCE_SYSTEM
    FROM date_range
)

SELECT * FROM date_attributes
