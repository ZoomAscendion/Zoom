{{ config(
    materialized='table'
) }}

-- Gold Time Dimension Table
WITH date_range AS (
    SELECT 
        DATEADD('day', ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) as date_key
    FROM (
        SELECT 1 as dummy FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) t1(c)
        CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) t2(c)
        CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) t3(c)
        CROSS JOIN (VALUES (1),(2),(3),(4)) t4(c)
    )
    QUALIFY date_key <= '2030-12-31'::DATE
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY date_key) as time_dimension_id,
    date_key,
    EXTRACT(YEAR FROM date_key) as year,
    EXTRACT(QUARTER FROM date_key) as quarter,
    EXTRACT(MONTH FROM date_key) as month,
    MONTHNAME(date_key) as month_name,
    EXTRACT(WEEK FROM date_key) as week_of_year,
    EXTRACT(DAY FROM date_key) as day_of_month,
    EXTRACT(DAYOFWEEK FROM date_key) as day_of_week,
    DAYNAME(date_key) as day_name,
    CASE WHEN EXTRACT(DAYOFWEEK FROM date_key) IN (1, 7) THEN TRUE ELSE FALSE END as is_weekend,
    CASE WHEN EXTRACT(DAYOFWEEK FROM date_key) BETWEEN 2 AND 6 THEN TRUE ELSE FALSE END as is_business_day,
    -- Fiscal year (assuming April to March)
    CASE 
        WHEN EXTRACT(MONTH FROM date_key) >= 4 THEN EXTRACT(YEAR FROM date_key)
        ELSE EXTRACT(YEAR FROM date_key) - 1
    END as fiscal_year,
    CASE 
        WHEN EXTRACT(MONTH FROM date_key) IN (4, 5, 6) THEN 1
        WHEN EXTRACT(MONTH FROM date_key) IN (7, 8, 9) THEN 2
        WHEN EXTRACT(MONTH FROM date_key) IN (10, 11, 12) THEN 3
        ELSE 4
    END as fiscal_quarter,
    -- Metadata columns
    CURRENT_DATE() as load_date,
    'SYSTEM_GENERATED' as source_system
FROM date_range
