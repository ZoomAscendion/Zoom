{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, LOAD_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_DIM_DATE_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SYSTEM_GENERATED', 'GOLD.GO_DIM_DATE', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}) WHERE PROCESS_NAME = 'GO_DIM_DATE_LOAD' AND DATE(EXECUTION_START_TIMESTAMP) = CURRENT_DATE()"
) }}

-- Date Dimension Generation
-- Creates a comprehensive date dimension for time-based analysis

WITH date_series AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) as date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years of dates (2020-2030)
),

date_attributes AS (
    SELECT 
        date_value as DATE_KEY,
        date_value as DATE_VALUE,
        YEAR(date_value) as YEAR,
        QUARTER(date_value) as QUARTER,
        MONTH(date_value) as MONTH,
        MONTHNAME(date_value) as MONTH_NAME,
        DAY(date_value) as DAY_OF_MONTH,
        DAYOFWEEK(date_value) as DAY_OF_WEEK,
        DAYNAME(date_value) as DAY_NAME,
        CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END as IS_WEEKEND,
        FALSE as IS_HOLIDAY, -- To be enhanced with holiday logic
        CASE 
            WHEN MONTH(date_value) >= 4 THEN YEAR(date_value)
            ELSE YEAR(date_value) - 1
        END as FISCAL_YEAR,
        CASE 
            WHEN MONTH(date_value) IN (4, 5, 6) THEN 1
            WHEN MONTH(date_value) IN (7, 8, 9) THEN 2
            WHEN MONTH(date_value) IN (10, 11, 12) THEN 3
            ELSE 4
        END as FISCAL_QUARTER,
        WEEKOFYEAR(date_value) as WEEK_OF_YEAR,
        CURRENT_DATE() as LOAD_DATE,
        CURRENT_DATE() as UPDATE_DATE,
        'SYSTEM_GENERATED' as SOURCE_SYSTEM
    FROM date_series
)

SELECT * FROM date_attributes
