{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (AUDIT_KEY, PIPELINE_NAME, PIPELINE_RUN_TIMESTAMP, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS, PROCESSED_BY, LOAD_DATE, SOURCE_SYSTEM) SELECT 'DATE_DIM_' || CURRENT_TIMESTAMP()::VARCHAR, 'GO_DIM_DATE_GENERATE', CURRENT_TIMESTAMP(), 'SYSTEM_GENERATED', 'GO_DIM_DATE', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_USER(), CURRENT_DATE(), 'DBT_GOLD_LAYER'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (AUDIT_KEY, PIPELINE_NAME, PIPELINE_RUN_TIMESTAMP, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_END_TIME, EXECUTION_DURATION_SECONDS, RECORDS_PROCESSED, EXECUTION_STATUS, PROCESSED_BY, LOAD_DATE, SOURCE_SYSTEM) SELECT 'DATE_DIM_' || CURRENT_TIMESTAMP()::VARCHAR, 'GO_DIM_DATE_GENERATE', CURRENT_TIMESTAMP(), 'SYSTEM_GENERATED', 'GO_DIM_DATE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 1, (SELECT COUNT(*) FROM {{ this }}), 'COMPLETED', CURRENT_USER(), CURRENT_DATE(), 'DBT_GOLD_LAYER'"
) }}

-- Gold Layer Date Dimension Table
-- Generates comprehensive date dimension for time-based analytics
-- Covers 10 years of dates with all necessary date attributes

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

date_transformations AS (
    SELECT 
        date_day::DATE AS DATE_KEY,
        YEAR(date_day)::NUMBER(4,0) AS YEAR,
        QUARTER(date_day)::NUMBER(1,0) AS QUARTER,
        MONTH(date_day)::NUMBER(2,0) AS MONTH,
        MONTHNAME(date_day)::VARCHAR(20) AS MONTH_NAME,
        WEEKOFYEAR(date_day)::NUMBER(2,0) AS WEEK_OF_YEAR,
        DAY(date_day)::NUMBER(2,0) AS DAY_OF_MONTH,
        DAYOFWEEK(date_day)::NUMBER(1,0) AS DAY_OF_WEEK,
        DAYNAME(date_day)::VARCHAR(20) AS DAY_NAME,
        CASE WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE ELSE FALSE END::BOOLEAN AS IS_WEEKEND,
        FALSE::BOOLEAN AS IS_HOLIDAY, -- To be updated with holiday logic
        CASE 
            WHEN MONTH(date_day) >= 4 THEN YEAR(date_day) 
            ELSE YEAR(date_day) - 1 
        END::NUMBER(4,0) AS FISCAL_YEAR,
        CASE 
            WHEN MONTH(date_day) IN (4,5,6) THEN 1
            WHEN MONTH(date_day) IN (7,8,9) THEN 2
            WHEN MONTH(date_day) IN (10,11,12) THEN 3
            ELSE 4
        END::NUMBER(1,0) AS FISCAL_QUARTER,
        CURRENT_DATE()::DATE AS LOAD_DATE,
        'SYSTEM_GENERATED'::VARCHAR(16777216) AS SOURCE_SYSTEM
    FROM date_spine
)

SELECT 
    DATE_KEY,
    YEAR,
    QUARTER,
    MONTH,
    MONTH_NAME,
    WEEK_OF_YEAR,
    DAY_OF_MONTH,
    DAY_OF_WEEK,
    DAY_NAME,
    IS_WEEKEND,
    IS_HOLIDAY,
    FISCAL_YEAR,
    FISCAL_QUARTER,
    LOAD_DATE,
    SOURCE_SYSTEM
FROM date_transformations
