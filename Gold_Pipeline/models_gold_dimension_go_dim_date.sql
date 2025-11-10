/*
  go_dim_date.sql
  Zoom Platform Analytics System - Date Dimension
  
  Author: Data Engineering Team
  Description: Standard date dimension for time-based analysis across all fact tables
  
  This model creates a comprehensive date dimension with calendar and fiscal year attributes
  to support temporal analysis and reporting requirements.
*/

{{ config(
    materialized='table',
    tags=['dimension', 'date'],
    cluster_by=['date_value']
) }}

-- Generate date spine for the specified range
WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" + var('start_date') + "' as date)",
        end_date="cast('" + var('end_date') + "' as date)"
    ) }}
),

-- Holiday calendar (basic implementation - can be enhanced with actual holiday data)
holidays AS (
    SELECT date_day AS holiday_date
    FROM date_spine
    WHERE 
        -- New Year's Day
        (MONTH(date_day) = 1 AND DAY(date_day) = 1)
        -- Independence Day
        OR (MONTH(date_day) = 7 AND DAY(date_day) = 4)
        -- Christmas Day
        OR (MONTH(date_day) = 12 AND DAY(date_day) = 25)
        -- Thanksgiving (4th Thursday of November - simplified)
        OR (MONTH(date_day) = 11 AND DAYOFWEEK(date_day) = 5 AND DAY(date_day) BETWEEN 22 AND 28)
),

-- Date dimension with all attributes
date_dimension AS (
    SELECT 
        -- Primary key
        ROW_NUMBER() OVER (ORDER BY ds.date_day) AS date_id,
        
        -- Core date attributes
        ds.date_day AS date_value,
        YEAR(ds.date_day) AS year,
        QUARTER(ds.date_day) AS quarter,
        MONTH(ds.date_day) AS month,
        MONTHNAME(ds.date_day) AS month_name,
        DAY(ds.date_day) AS day_of_month,
        DAYOFWEEK(ds.date_day) AS day_of_week,
        DAYNAME(ds.date_day) AS day_name,
        
        -- Weekend and holiday flags
        CASE 
            WHEN DAYOFWEEK(ds.date_day) IN (1, 7) THEN TRUE 
            ELSE FALSE 
        END AS is_weekend,
        
        CASE 
            WHEN h.holiday_date IS NOT NULL THEN TRUE 
            ELSE FALSE 
        END AS is_holiday,
        
        -- Fiscal year attributes (assuming fiscal year starts July 1)
        CASE 
            WHEN MONTH(ds.date_day) >= 7 THEN YEAR(ds.date_day) + 1
            ELSE YEAR(ds.date_day)
        END AS fiscal_year,
        
        CASE 
            WHEN MONTH(ds.date_day) IN (7, 8, 9) THEN 1
            WHEN MONTH(ds.date_day) IN (10, 11, 12) THEN 2
            WHEN MONTH(ds.date_day) IN (1, 2, 3) THEN 3
            WHEN MONTH(ds.date_day) IN (4, 5, 6) THEN 4
        END AS fiscal_quarter,
        
        -- Additional date attributes
        WEEKOFYEAR(ds.date_day) AS week_of_year,
        'Q' || QUARTER(ds.date_day) AS quarter_name,
        TO_CHAR(ds.date_day, 'MON-YYYY') AS month_year,
        
        -- Metadata columns
        CURRENT_DATE AS load_date,
        CURRENT_DATE AS update_date,
        'DBT_GOLD_PIPELINE' AS source_system
        
    FROM date_spine ds
    LEFT JOIN holidays h ON ds.date_day = h.holiday_date
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
    quarter_name,
    month_year,
    load_date,
    update_date,
    source_system
FROM date_dimension
ORDER BY date_value