/*
  Model: go_dim_date
  Author: Data Engineering Team
  Created: 2024-12-19
  Description: Standard date dimension for time-based analysis across all fact tables
  
  This model creates a comprehensive date dimension covering the full range of dates
  needed for analysis, ensuring each date appears only once with complete temporal attributes.
  
  Dependencies: go_process_audit
  Materialization: Table
  Clustering: DATE_KEY
  Uniqueness: Single unique record per calendar date with DATE_KEY as primary identifier
*/

{{ config(
    materialized='table',
    cluster_by=['DATE_KEY'],
    tags=['dimension', 'gold_layer', 'date'],
    on_schema_change='fail'
) }}

-- Generate comprehensive date dimension
WITH date_range AS (
    SELECT 
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '{{ var("start_date") }}'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years of dates
),

date_attributes AS (
    SELECT 
        date_value,
        
        -- Basic date components
        YEAR(date_value) AS year_num,
        QUARTER(date_value) AS quarter_num,
        MONTH(date_value) AS month_num,
        MONTHNAME(date_value) AS month_name,
        DAY(date_value) AS day_of_month,
        DAYOFWEEK(date_value) AS day_of_week_num,
        DAYNAME(date_value) AS day_name,
        DAYOFYEAR(date_value) AS day_of_year,
        WEEKOFYEAR(date_value) AS week_of_year,
        
        -- Weekend and weekday flags
        CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        CASE WHEN DAYOFWEEK(date_value) NOT IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekday,
        
        -- Fiscal year calculations (assuming April start)
        CASE 
            WHEN MONTH(date_value) >= 4 THEN YEAR(date_value)
            ELSE YEAR(date_value) - 1
        END AS fiscal_year,
        
        CASE 
            WHEN MONTH(date_value) BETWEEN 4 AND 6 THEN 1
            WHEN MONTH(date_value) BETWEEN 7 AND 9 THEN 2
            WHEN MONTH(date_value) BETWEEN 10 AND 12 THEN 3
            ELSE 4
        END AS fiscal_quarter,
        
        -- Holiday flags (basic US holidays)
        CASE 
            WHEN MONTH(date_value) = 1 AND DAY(date_value) = 1 THEN TRUE  -- New Year's Day
            WHEN MONTH(date_value) = 7 AND DAY(date_value) = 4 THEN TRUE  -- Independence Day
            WHEN MONTH(date_value) = 12 AND DAY(date_value) = 25 THEN TRUE -- Christmas
            ELSE FALSE
        END AS is_holiday,
        
        -- Date formatting variations
        TO_CHAR(date_value, 'YYYY-MM-DD') AS date_string,
        TO_CHAR(date_value, 'YYYYMMDD') AS date_key_string,
        TO_CHAR(date_value, 'Mon YYYY') AS month_year_string,
        TO_CHAR(date_value, 'YYYY-Q"Q"') AS quarter_year_string,
        
        -- Relative date calculations
        CASE WHEN date_value = CURRENT_DATE() THEN TRUE ELSE FALSE END AS is_today,
        CASE WHEN date_value = CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_yesterday,
        CASE WHEN date_value BETWEEN CURRENT_DATE() - 7 AND CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_last_7_days,
        CASE WHEN date_value BETWEEN CURRENT_DATE() - 30 AND CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_last_30_days,
        CASE WHEN date_value BETWEEN DATE_TRUNC('MONTH', CURRENT_DATE()) AND CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_month_to_date,
        CASE WHEN date_value BETWEEN DATE_TRUNC('QUARTER', CURRENT_DATE()) AND CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_quarter_to_date,
        CASE WHEN date_value BETWEEN DATE_TRUNC('YEAR', CURRENT_DATE()) AND CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS is_year_to_date,
        
        -- First and last day flags
        CASE WHEN DAY(date_value) = 1 THEN TRUE ELSE FALSE END AS is_first_day_of_month,
        CASE WHEN date_value = LAST_DAY(date_value) THEN TRUE ELSE FALSE END AS is_last_day_of_month,
        CASE WHEN date_value = DATE_TRUNC('QUARTER', date_value) THEN TRUE ELSE FALSE END AS is_first_day_of_quarter,
        CASE WHEN date_value = LAST_DAY(DATE_TRUNC('QUARTER', date_value) + INTERVAL '2 MONTH') THEN TRUE ELSE FALSE END AS is_last_day_of_quarter,
        CASE WHEN MONTH(date_value) = 1 AND DAY(date_value) = 1 THEN TRUE ELSE FALSE END AS is_first_day_of_year,
        CASE WHEN MONTH(date_value) = 12 AND DAY(date_value) = 31 THEN TRUE ELSE FALSE END AS is_last_day_of_year
        
    FROM date_range
    WHERE date_value <= CURRENT_DATE() + INTERVAL '2 years'
)

SELECT 
    -- Primary key
    date_value AS DATE_KEY,
    
    -- Auto-increment surrogate key (will be populated by Snowflake)
    NULL AS DATE_ID,
    
    -- Date value
    date_value AS DATE_VALUE,
    
    -- Basic date components
    year_num AS YEAR,
    quarter_num AS QUARTER,
    month_num AS MONTH,
    month_name AS MONTH_NAME,
    day_of_month AS DAY_OF_MONTH,
    day_of_week_num AS DAY_OF_WEEK,
    day_name AS DAY_NAME,
    day_of_year AS DAY_OF_YEAR,
    week_of_year AS WEEK_OF_YEAR,
    
    -- Weekend and weekday flags
    is_weekend AS IS_WEEKEND,
    is_weekday AS IS_WEEKDAY,
    
    -- Holiday flag
    is_holiday AS IS_HOLIDAY,
    
    -- Fiscal year attributes
    fiscal_year AS FISCAL_YEAR,
    fiscal_quarter AS FISCAL_QUARTER,
    
    -- Date string formats
    date_string AS DATE_STRING,
    date_key_string AS DATE_KEY_STRING,
    month_year_string AS MONTH_YEAR_STRING,
    quarter_year_string AS QUARTER_YEAR_STRING,
    
    -- Relative date flags
    is_today AS IS_TODAY,
    is_yesterday AS IS_YESTERDAY,
    is_last_7_days AS IS_LAST_7_DAYS,
    is_last_30_days AS IS_LAST_30_DAYS,
    is_month_to_date AS IS_MONTH_TO_DATE,
    is_quarter_to_date AS IS_QUARTER_TO_DATE,
    is_year_to_date AS IS_YEAR_TO_DATE,
    
    -- First and last day flags
    is_first_day_of_month AS IS_FIRST_DAY_OF_MONTH,
    is_last_day_of_month AS IS_LAST_DAY_OF_MONTH,
    is_first_day_of_quarter AS IS_FIRST_DAY_OF_QUARTER,
    is_last_day_of_quarter AS IS_LAST_DAY_OF_QUARTER,
    is_first_day_of_year AS IS_FIRST_DAY_OF_YEAR,
    is_last_day_of_year AS IS_LAST_DAY_OF_YEAR,
    
    -- Standard metadata columns
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    '{{ var("source_system") }}' AS SOURCE_SYSTEM
    
FROM date_attributes
ORDER BY date_value