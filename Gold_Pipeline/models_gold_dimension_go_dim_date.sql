-- =====================================================
-- DATE DIMENSION MODEL
-- Project: Zoom Platform Analytics System - Gold Layer
-- Purpose: Standard date dimension for time-based analysis
-- Materialization: Table
-- Dependencies: None
-- =====================================================

{{ config(
    materialized='table',
    tags=['dimension', 'date'],
    cluster_by=['date_value'],
    pre_hook="{{ log('Starting GO_DIM_DATE transformation', info=True) }}",
    post_hook="{{ log('Completed GO_DIM_DATE transformation', info=True) }}"
) }}

-- Generate comprehensive date dimension
WITH date_range AS (
    -- Generate date range from 2020 to 2030 (10 years)
    SELECT 
        DATEADD('day', 
            ROW_NUMBER() OVER (ORDER BY NULL) - 1, 
            DATE('2020-01-01')
        ) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years + leap days
),

date_attributes AS (
    SELECT 
        date_value,
        
        -- Basic date components
        YEAR(date_value) AS year,
        QUARTER(date_value) AS quarter,
        MONTH(date_value) AS month,
        MONTHNAME(date_value) AS month_name,
        DAY(date_value) AS day_of_month,
        DAYOFWEEK(date_value) AS day_of_week,
        DAYNAME(date_value) AS day_name,
        
        -- Weekend flag
        CASE 
            WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE 
            ELSE FALSE 
        END AS is_weekend,
        
        -- Holiday flag (basic implementation - can be enhanced)
        CASE 
            WHEN (MONTH(date_value) = 1 AND DAY(date_value) = 1) THEN TRUE  -- New Year
            WHEN (MONTH(date_value) = 7 AND DAY(date_value) = 4) THEN TRUE  -- Independence Day
            WHEN (MONTH(date_value) = 12 AND DAY(date_value) = 25) THEN TRUE -- Christmas
            ELSE FALSE 
        END AS is_holiday,
        
        -- Fiscal year (assuming July 1 - June 30)
        CASE 
            WHEN MONTH(date_value) >= 7 THEN YEAR(date_value) + 1
            ELSE YEAR(date_value)
        END AS fiscal_year,
        
        -- Fiscal quarter
        CASE 
            WHEN MONTH(date_value) IN (7, 8, 9) THEN 1
            WHEN MONTH(date_value) IN (10, 11, 12) THEN 2
            WHEN MONTH(date_value) IN (1, 2, 3) THEN 3
            WHEN MONTH(date_value) IN (4, 5, 6) THEN 4
        END AS fiscal_quarter,
        
        -- Week of year
        WEEKOFYEAR(date_value) AS week_of_year,
        
        -- Quarter name
        'Q' || QUARTER(date_value) AS quarter_name,
        
        -- Month-Year format
        TO_CHAR(date_value, 'MON-YYYY') AS month_year
        
    FROM date_range
    WHERE date_value <= DATE('2030-12-31')
),

final_date_dimension AS (
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
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        'DBT_GOLD_PIPELINE' AS source_system
        
    FROM date_attributes
)

SELECT * FROM final_date_dimension
ORDER BY date_value

-- Add documentation
{{ doc("go_dim_date", "
Date Dimension Table

This dimension table provides a comprehensive date hierarchy for time-based analysis
across all fact tables in the Gold layer. It includes:

- Standard calendar attributes (year, quarter, month, day)
- Fiscal year calculations (July 1 - June 30)
- Weekend and holiday flags
- Week of year calculations
- Formatted date strings for reporting

Key Features:
- Covers 10-year range (2020-2030)
- Supports both calendar and fiscal year analysis
- Optimized with clustering on date_value
- Ready for joins with all fact tables

Usage:
- Join with fact tables on date columns
- Use for time-based filtering and grouping
- Support for fiscal and calendar year reporting
- Enable drill-down from year to day level
") }}