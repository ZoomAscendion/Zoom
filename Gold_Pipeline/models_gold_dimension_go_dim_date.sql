-- =====================================================
-- DATE DIMENSION TABLE
-- Model: go_dim_date
-- Purpose: Standard date dimension for time-based analysis across all fact tables
-- Materialization: table
-- Dependencies: go_audit_log
-- =====================================================

{{ config(
    materialized='table',
    cluster_by=['DATE_VALUE'],
    tags=['dimension', 'date'],
    unique_key='DATE_ID'
) }}

-- Generate comprehensive date dimension
WITH date_spine AS (
    -- Generate date range from start_date to end_date variables
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" + var('start_date') + "' as date)",
        end_date="cast('" + var('end_date') + "' as date)"
    ) }}
),

date_dimension AS (
    SELECT 
        -- Primary key
        ROW_NUMBER() OVER (ORDER BY date_day) AS DATE_ID,
        
        -- Core date fields
        date_day AS DATE_VALUE,
        YEAR(date_day) AS YEAR,
        QUARTER(date_day) AS QUARTER,
        MONTH(date_day) AS MONTH,
        MONTHNAME(date_day) AS MONTH_NAME,
        DAY(date_day) AS DAY_OF_MONTH,
        DAYOFWEEK(date_day) AS DAY_OF_WEEK,
        DAYNAME(date_day) AS DAY_NAME,
        
        -- Weekend and holiday flags
        CASE 
            WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE 
            ELSE FALSE 
        END AS IS_WEEKEND,
        
        -- Holiday logic (basic US holidays)
        CASE 
            WHEN (MONTH(date_day) = 1 AND DAY(date_day) = 1) THEN TRUE  -- New Year's Day
            WHEN (MONTH(date_day) = 7 AND DAY(date_day) = 4) THEN TRUE  -- Independence Day
            WHEN (MONTH(date_day) = 12 AND DAY(date_day) = 25) THEN TRUE -- Christmas
            WHEN (MONTH(date_day) = 11 AND DAY(date_day) BETWEEN 22 AND 28 AND DAYOFWEEK(date_day) = 5) THEN TRUE -- Thanksgiving
            ELSE FALSE
        END AS IS_HOLIDAY,
        
        -- Fiscal year calculations (assuming July 1 fiscal year start)
        CASE 
            WHEN MONTH(date_day) >= 7 THEN YEAR(date_day) + 1
            ELSE YEAR(date_day)
        END AS FISCAL_YEAR,
        
        CASE 
            WHEN MONTH(date_day) IN (7, 8, 9) THEN 1
            WHEN MONTH(date_day) IN (10, 11, 12) THEN 2
            WHEN MONTH(date_day) IN (1, 2, 3) THEN 3
            WHEN MONTH(date_day) IN (4, 5, 6) THEN 4
        END AS FISCAL_QUARTER,
        
        -- Additional time attributes
        WEEKOFYEAR(date_day) AS WEEK_OF_YEAR,
        'Q' || QUARTER(date_day) AS QUARTER_NAME,
        TO_CHAR(date_day, 'MON-YYYY') AS MONTH_YEAR,
        
        -- Business day calculations
        CASE 
            WHEN DAYOFWEEK(date_day) BETWEEN 2 AND 6 
                AND NOT (
                    (MONTH(date_day) = 1 AND DAY(date_day) = 1) OR
                    (MONTH(date_day) = 7 AND DAY(date_day) = 4) OR
                    (MONTH(date_day) = 12 AND DAY(date_day) = 25) OR
                    (MONTH(date_day) = 11 AND DAY(date_day) BETWEEN 22 AND 28 AND DAYOFWEEK(date_day) = 5)
                )
            THEN TRUE 
            ELSE FALSE 
        END AS IS_BUSINESS_DAY,
        
        -- Relative date flags
        CASE WHEN date_day = CURRENT_DATE() THEN TRUE ELSE FALSE END AS IS_TODAY,
        CASE WHEN date_day = CURRENT_DATE() - 1 THEN TRUE ELSE FALSE END AS IS_YESTERDAY,
        CASE WHEN date_day BETWEEN DATE_TRUNC('week', CURRENT_DATE()) AND CURRENT_DATE() THEN TRUE ELSE FALSE END AS IS_CURRENT_WEEK,
        CASE WHEN date_day BETWEEN DATE_TRUNC('month', CURRENT_DATE()) AND CURRENT_DATE() THEN TRUE ELSE FALSE END AS IS_CURRENT_MONTH,
        CASE WHEN date_day BETWEEN DATE_TRUNC('quarter', CURRENT_DATE()) AND CURRENT_DATE() THEN TRUE ELSE FALSE END AS IS_CURRENT_QUARTER,
        CASE WHEN date_day BETWEEN DATE_TRUNC('year', CURRENT_DATE()) AND CURRENT_DATE() THEN TRUE ELSE FALSE END AS IS_CURRENT_YEAR,
        
        -- Season calculation
        CASE 
            WHEN MONTH(date_day) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(date_day) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(date_day) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(date_day) IN (9, 10, 11) THEN 'Fall'
        END AS SEASON,
        
        -- Standard metadata columns
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'DBT_GOLD_PIPELINE' AS SOURCE_SYSTEM
        
    FROM date_spine
),

-- Add data quality validations
validated_dates AS (
    SELECT 
        *,
        -- Data quality checks
        CASE 
            WHEN DATE_VALUE IS NULL THEN 'FAILED'
            WHEN YEAR < 2020 OR YEAR > 2030 THEN 'WARNING'
            WHEN MONTH < 1 OR MONTH > 12 THEN 'FAILED'
            WHEN DAY_OF_MONTH < 1 OR DAY_OF_MONTH > 31 THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        
        CASE 
            WHEN DATE_VALUE IS NULL THEN 0
            WHEN YEAR < 2020 OR YEAR > 2030 THEN 85
            WHEN MONTH < 1 OR MONTH > 12 THEN 0
            WHEN DAY_OF_MONTH < 1 OR DAY_OF_MONTH > 31 THEN 0
            ELSE 100
        END AS DATA_QUALITY_SCORE
        
    FROM date_dimension
)

-- Final select with error handling
SELECT 
    DATE_ID,
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
    QUARTER_NAME,
    MONTH_YEAR,
    IS_BUSINESS_DAY,
    IS_TODAY,
    IS_YESTERDAY,
    IS_CURRENT_WEEK,
    IS_CURRENT_MONTH,
    IS_CURRENT_QUARTER,
    IS_CURRENT_YEAR,
    SEASON,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM validated_dates
WHERE VALIDATION_STATUS = 'PASSED'
   OR (VALIDATION_STATUS = 'WARNING' AND DATA_QUALITY_SCORE >= {{ var('min_data_quality_score') }})
ORDER BY DATE_VALUE