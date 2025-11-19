{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_READ, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key([\"'GO_DIM_DATE'\", 'CURRENT_TIMESTAMP()']) }}', 'GO_DIM_DATE_LOAD', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SYSTEM_GENERATED', 'GO_DIM_DATE', 0, 'DBT_PIPELINE', 'DBT_SYSTEM', CURRENT_DATE, CURRENT_DATE, 'DBT_GOLD_PIPELINE'",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PROCESS_NAME = 'GO_DIM_DATE_LOAD' AND EXECUTION_STATUS = 'RUNNING'"
) }}

-- Gold Dimension: Date Dimension
-- Standard date dimension for time-based analysis across all fact tables

WITH date_series AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years of dates (2020-2030)
)

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
    FALSE AS IS_HOLIDAY, -- To be enhanced with holiday logic
    CASE 
        WHEN MONTH(date_value) >= 4 THEN YEAR(date_value)
        ELSE YEAR(date_value) - 1
    END AS FISCAL_YEAR,
    CASE 
        WHEN MONTH(date_value) IN (4, 5, 6) THEN 1
        WHEN MONTH(date_value) IN (7, 8, 9) THEN 2
        WHEN MONTH(date_value) IN (10, 11, 12) THEN 3
        ELSE 4
    END AS FISCAL_QUARTER,
    WEEKOFYEAR(date_value) AS WEEK_OF_YEAR,
    CURRENT_DATE AS LOAD_DATE,
    CURRENT_DATE AS UPDATE_DATE,
    'SYSTEM_GENERATED' AS SOURCE_SYSTEM
FROM date_series
