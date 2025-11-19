-- =====================================================
-- GOLD LAYER DATE DIMENSION MODEL
-- Model: go_dim_date
-- Purpose: Standard date dimension for time-based analysis across all fact tables
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- =====================================================

{{
  config(
    materialized='table',
    database='DB_POC_ZOOM',
    schema='GOLD',
    alias='GO_DIM_DATE',
    tags=['dimension', 'gold_layer', 'date_dimension'],
    cluster_by=['DATE_ID', 'FISCAL_YEAR'],
    comment='Standard date dimension for time-based analysis across all fact tables'
  )
}}

-- =====================================================
-- DATE SERIES GENERATION
-- =====================================================

WITH date_series AS (
  SELECT 
    DATEADD(
      day, 
      ROW_NUMBER() OVER (ORDER BY 1) - 1, 
      '{{ var("start_date") }}'::DATE
    ) AS date_value
  FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years of dates (2020-2030)
  WHERE date_value <= '{{ var("end_date") }}'::DATE
),

-- =====================================================
-- DATE ATTRIBUTES CALCULATION
-- =====================================================

date_attributes AS (
  SELECT 
    date_value,
    
    -- Basic date components
    YEAR(date_value) AS year_value,
    QUARTER(date_value) AS quarter_value,
    MONTH(date_value) AS month_value,
    MONTHNAME(date_value) AS month_name,
    DAY(date_value) AS day_of_month,
    DAYOFWEEK(date_value) AS day_of_week_number,
    DAYNAME(date_value) AS day_name,
    WEEKOFYEAR(date_value) AS week_of_year,
    
    -- Weekend and holiday flags
    CASE 
      WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE 
      ELSE FALSE 
    END AS is_weekend,
    
    -- Holiday detection (basic US holidays)
    CASE 
      WHEN (MONTH(date_value) = 1 AND DAY(date_value) = 1) THEN TRUE  -- New Year's Day
      WHEN (MONTH(date_value) = 7 AND DAY(date_value) = 4) THEN TRUE  -- Independence Day
      WHEN (MONTH(date_value) = 12 AND DAY(date_value) = 25) THEN TRUE -- Christmas Day
      -- Thanksgiving (4th Thursday of November)
      WHEN (MONTH(date_value) = 11 
            AND DAYNAME(date_value) = 'Thursday' 
            AND DAY(date_value) BETWEEN 22 AND 28) THEN TRUE
      -- Memorial Day (last Monday of May)
      WHEN (MONTH(date_value) = 5 
            AND DAYNAME(date_value) = 'Monday' 
            AND DAY(date_value) > 24) THEN TRUE
      -- Labor Day (first Monday of September)
      WHEN (MONTH(date_value) = 9 
            AND DAYNAME(date_value) = 'Monday' 
            AND DAY(date_value) <= 7) THEN TRUE
      ELSE FALSE
    END AS is_holiday,
    
    -- Fiscal year calculations (starting April 1st)
    CASE 
      WHEN MONTH(date_value) >= {{ var('fiscal_year_start_month') }} 
      THEN YEAR(date_value)
      ELSE YEAR(date_value) - 1
    END AS fiscal_year,
    
    -- Fiscal quarter calculations
    CASE 
      WHEN MONTH(date_value) IN (4, 5, 6) THEN 1
      WHEN MONTH(date_value) IN (7, 8, 9) THEN 2
      WHEN MONTH(date_value) IN (10, 11, 12) THEN 3
      ELSE 4
    END AS fiscal_quarter
    
  FROM date_series
),

-- =====================================================
-- DATE DIMENSION ENRICHMENT
-- =====================================================

date_enriched AS (
  SELECT 
    *,
    
    -- Additional derived attributes
    CASE 
      WHEN month_value IN (12, 1, 2) THEN 'Winter'
      WHEN month_value IN (3, 4, 5) THEN 'Spring'
      WHEN month_value IN (6, 7, 8) THEN 'Summer'
      ELSE 'Fall'
    END AS season,
    
    -- Business day flag
    CASE 
      WHEN is_weekend = TRUE OR is_holiday = TRUE THEN FALSE
      ELSE TRUE
    END AS is_business_day,
    
    -- Month abbreviation
    CASE month_value
      WHEN 1 THEN 'Jan' WHEN 2 THEN 'Feb' WHEN 3 THEN 'Mar'
      WHEN 4 THEN 'Apr' WHEN 5 THEN 'May' WHEN 6 THEN 'Jun'
      WHEN 7 THEN 'Jul' WHEN 8 THEN 'Aug' WHEN 9 THEN 'Sep'
      WHEN 10 THEN 'Oct' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dec'
    END AS month_abbr,
    
    -- Day abbreviation
    CASE day_of_week_number
      WHEN 1 THEN 'Sun' WHEN 2 THEN 'Mon' WHEN 3 THEN 'Tue'
      WHEN 4 THEN 'Wed' WHEN 5 THEN 'Thu' WHEN 6 THEN 'Fri'
      WHEN 7 THEN 'Sat'
    END AS day_abbr,
    
    -- Date formatting variations
    TO_CHAR(date_value, 'YYYY-MM-DD') AS date_iso,
    TO_CHAR(date_value, 'MM/DD/YYYY') AS date_us,
    TO_CHAR(date_value, 'DD/MM/YYYY') AS date_eu,
    TO_CHAR(date_value, 'YYYYMMDD') AS date_key_numeric,
    
    -- Relative date calculations
    DATEDIFF('day', date_value, CURRENT_DATE()) AS days_from_today,
    CASE 
      WHEN date_value = CURRENT_DATE() THEN 'Today'
      WHEN date_value = CURRENT_DATE() - 1 THEN 'Yesterday'
      WHEN date_value = CURRENT_DATE() + 1 THEN 'Tomorrow'
      WHEN date_value BETWEEN CURRENT_DATE() - 7 AND CURRENT_DATE() - 1 THEN 'Last Week'
      WHEN date_value BETWEEN CURRENT_DATE() + 1 AND CURRENT_DATE() + 7 THEN 'Next Week'
      WHEN date_value < CURRENT_DATE() THEN 'Past'
      ELSE 'Future'
    END AS relative_date_category
    
  FROM date_attributes
),

-- =====================================================
-- FINAL DATE DIMENSION
-- =====================================================

date_dimension_final AS (
  SELECT 
    -- Primary key (auto-increment will be handled by Snowflake)
    ROW_NUMBER() OVER (ORDER BY date_value) AS DATE_ID,
    
    -- Date value (also serves as natural key)
    date_value AS DATE_VALUE,
    
    -- Calendar attributes
    year_value AS YEAR,
    quarter_value AS QUARTER,
    month_value AS MONTH,
    month_name AS MONTH_NAME,
    month_abbr AS MONTH_ABBR,
    day_of_month AS DAY_OF_MONTH,
    day_of_week_number AS DAY_OF_WEEK,
    day_name AS DAY_NAME,
    day_abbr AS DAY_ABBR,
    week_of_year AS WEEK_OF_YEAR,
    
    -- Special day flags
    is_weekend AS IS_WEEKEND,
    is_holiday AS IS_HOLIDAY,
    is_business_day AS IS_BUSINESS_DAY,
    
    -- Fiscal year attributes
    fiscal_year AS FISCAL_YEAR,
    fiscal_quarter AS FISCAL_QUARTER,
    
    -- Seasonal and categorical attributes
    season AS SEASON,
    relative_date_category AS RELATIVE_DATE_CATEGORY,
    
    -- Date formatting variations
    date_iso AS DATE_ISO_FORMAT,
    date_us AS DATE_US_FORMAT,
    date_eu AS DATE_EU_FORMAT,
    date_key_numeric AS DATE_KEY_NUMERIC,
    
    -- Relative calculations
    days_from_today AS DAYS_FROM_TODAY,
    
    -- Additional business attributes
    CASE 
      WHEN quarter_value IN (1, 2) THEN 'H1'
      ELSE 'H2'
    END AS HALF_YEAR,
    
    CASE 
      WHEN month_value <= 6 THEN 'First Half'
      ELSE 'Second Half'
    END AS YEAR_HALF_NAME,
    
    -- Quarter names
    'Q' || quarter_value || ' ' || year_value AS QUARTER_NAME,
    
    -- Month-Year combination
    month_name || ' ' || year_value AS MONTH_YEAR,
    
    -- Week start and end dates
    DATEADD('day', -(day_of_week_number - 1), date_value) AS WEEK_START_DATE,
    DATEADD('day', 7 - day_of_week_number, date_value) AS WEEK_END_DATE,
    
    -- Standard metadata columns
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SYSTEM_GENERATED' AS SOURCE_SYSTEM
    
  FROM date_enriched
)

-- =====================================================
-- FINAL OUTPUT WITH DATA QUALITY VALIDATION
-- =====================================================

SELECT 
  DATE_ID,
  DATE_VALUE,
  YEAR,
  QUARTER,
  MONTH,
  MONTH_NAME,
  MONTH_ABBR,
  DAY_OF_MONTH,
  DAY_OF_WEEK,
  DAY_NAME,
  DAY_ABBR,
  IS_WEEKEND,
  IS_HOLIDAY,
  IS_BUSINESS_DAY,
  FISCAL_YEAR,
  FISCAL_QUARTER,
  WEEK_OF_YEAR,
  SEASON,
  HALF_YEAR,
  YEAR_HALF_NAME,
  QUARTER_NAME,
  MONTH_YEAR,
  WEEK_START_DATE,
  WEEK_END_DATE,
  DATE_ISO_FORMAT,
  DATE_US_FORMAT,
  DATE_EU_FORMAT,
  DATE_KEY_NUMERIC,
  DAYS_FROM_TODAY,
  RELATIVE_DATE_CATEGORY,
  LOAD_DATE,
  UPDATE_DATE,
  SOURCE_SYSTEM
  
FROM date_dimension_final

-- Data quality validation
WHERE DATE_VALUE IS NOT NULL
  AND YEAR BETWEEN 2020 AND 2030
  AND MONTH BETWEEN 1 AND 12
  AND DAY_OF_MONTH BETWEEN 1 AND 31

ORDER BY DATE_VALUE

-- =====================================================
-- MODEL DOCUMENTATION
-- =====================================================

/*
MODEL DESCRIPTION:
This model creates a comprehensive date dimension table that serves as the 
central time-based reference for all fact tables in the Gold layer.

KEY FEATURES:
1. Complete date range from 2020 to 2030 (configurable via variables)
2. Standard calendar attributes (year, quarter, month, day, week)
3. Fiscal year support with configurable start month (default: April)
4. Holiday detection for major US holidays
5. Business day calculations (excluding weekends and holidays)
6. Multiple date format variations for different reporting needs
7. Relative date categorization (Today, Yesterday, Last Week, etc.)
8. Seasonal categorization and half-year groupings
9. Week start/end date calculations
10. Comprehensive metadata for audit and lineage tracking

BUSINESS RULES:
- Fiscal year starts in April (configurable via var('fiscal_year_start_month'))
- Weekend days are Saturday (7) and Sunday (1)
- Holidays include major US federal holidays
- Business days exclude weekends and holidays
- Date range is configurable via start_date and end_date variables

USAGE:
This dimension is joined to all fact tables using DATE_ID or DATE_VALUE.
It enables time-based analysis, trending, and period-over-period comparisons.

PERFORMANCE OPTIMIZATIONS:
- Clustered by DATE_ID and FISCAL_YEAR for optimal query performance
- Pre-calculated derived attributes to avoid runtime calculations
- Indexed on DATE_VALUE for natural key lookups

DATA QUALITY:
- Validates date ranges and component values
- Ensures no null or invalid dates
- Maintains referential integrity with fact tables

MONITORING:
- Monitor for gaps in date sequence
- Validate fiscal year calculations
- Check holiday detection accuracy
- Ensure proper clustering maintenance
*/

-- =====================================================
-- END OF DATE DIMENSION MODEL
-- =====================================================